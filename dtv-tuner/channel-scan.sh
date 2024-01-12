#!/bin/sh
# Mirakurun/mirakc channel yaml output  by uru (https://twitter.com/uru_2)
#
# require:
#   stz2012/epgdump
#   xmllint (libxml2 tools)
#   ISDB-T/S record software
#     recpt1, dvbv5-zap & Chinachu/dvbconf-for-isdb

set -eu
export LANG=C.UTF-8

# example: recpt1
readonly RECORD_COMMAND_GR='recpt1 --device /dev/pxmlt8video0 <channel> <record_second> <output>'
readonly RECORD_COMMAND_BSCS='recpt1 --device /dev/pxmlt8video0 <channel> <record_second> <output>'
# example: dvbv5-zap
#readonly RECORD_COMMAND_GR='dvbv5-zap -a 1 -c dvbv5_channels_isdbt.conf -s -r -P <channel> -t <record_second> -o <output>'
#readonly RECORD_COMMAND_BSCS='dvbv5-zap -a 0 -c dvbv5_channels_isdbs.conf -s -r -P <channel> -t <record_second> -o <output>'
readonly CONF_MIRAKURUN='channels.yml'
readonly CONF_MIRAKC='channels_mirakc.yml'
readonly RECORD_SECOND=10

# dump epg
dump_epg() {
  ch="${1}"
  type="${2}"
  output_ts="${workdir}/${ch}.ts"
  output_xml="${workdir}/${ch}.xml"

  cmd_base=''
  if [ "${type}" = 'GR' ]; then
    cmd_base="${RECORD_COMMAND_GR}"
  elif [ "${type}" = 'BS' ] || [ "${type}" = 'CS' ]; then
    cmd_base="${RECORD_COMMAND_BSCS}"
  fi
  if [ -z "${cmd_base}" ]; then
    return 0
  fi

  echo "[Channel: ${ch}]" >&2

  # generate record command
  rec_cmd="$(echo "${cmd_base}" | sed -e "s/<channel>/${ch}/" -e "s/<record_second>/${RECORD_SECOND}/" -e "s;<output>;${output_ts};")"

  # execute record command
  set +e
  ${rec_cmd}
  set -e

  # dump epg
  opt_type=""
  if [ -f "${output_ts}" ]; then
    if [ "${type}" = 'GR' ]; then
      opt_type="${ch}"
    elif [ "${type}" = 'BS' ]; then
      opt_type='/BS'
    elif [ "${type}" = 'CS' ]; then
      opt_type='/CS'
    fi
    epgdump "${opt_type}" "${output_ts}" "${output_xml}"

    rm -f "${output_ts}"
  fi

  return 0
}

# parse epg
parse_epg() {
  epg_xml="${1}"
  output="${2}"
  div="${3}"

  for i in $(seq 1 "$(xmllint --xpath 'count(/tv/channel)' "${epg_xml}")"); do
    tp="$(xmllint --xpath "string(/tv/channel[${i}]/@tp)" "${epg_xml}")"
    service="$(xmllint --xpath "string(/tv/channel[${i}]/service_id/text())" "${epg_xml}")"
    name="$(xmllint --xpath "string(/tv/channel[${i}]/display-name/text())" "${epg_xml}")"

    if [ -z "${name}" ]; then
      continue
    fi

    # sort order
    sort_ch=''
    if [ "${div}" = '1' ]; then
      sort_ch="$(printf "%02d" "$(basename "${epg_xml}" .xml)")"
    elif [ "${div}" = '2' ]; then
      sort_ch="$(printf "%02d" "$(basename "${epg_xml}" .xml | cut -c 2-)")"
    elif [ "${div}" = '3' ]; then
      sort_ch="$(echo "${tp}" | sed -e 's/BS//' -e 's/_/ /' | awk '{printf("%02d%d", $1, $2)}')"
    elif [ "${div}" = '4' ]; then
      sort_ch="$(printf "%02d" "$(echo "${tp}" | cut -c 3-)")"
    fi
    sort_service="$(printf "%05d" "${service}")"

    echo "${div}|${sort_ch}|${sort_service}|${tp}|${service}|${name}" >> "${output}"

    if [ "${div}" = '1' ] || [ "${div}" = '2' ]; then
      # GR first service only
      break
    fi
  done

  return 0
}



# find require tools
if [ ! "$(which epgdump)" ]; then
  echo 'require epgdump' >&2
  return 1
fi
if [ ! "$(which xmllint)" ]; then
  echo 'require xmllint' >&2
  return 1
fi

# create working
workdir="$(mktemp -d)"

# dump epg GR channels
for c in $(seq 13 62); do
  ch="${c}"
  dump_epg "${ch}" GR
done
for c in $(seq 13 63); do
  ch="C${c}"
  dump_epg "${ch}" GR
done

# dump epg BS channels
for c in $(seq -w 1 2 23); do
  ch="BS${c}_0"
  dump_epg "${ch}" BS
done

# dump epg CS channels
for c in $(seq 2 2 24); do
  ch="CS${c}"
  dump_epg "${ch}" CS
done

ch_temp="${workdir}/scan_ch.tmp"
touch "${ch_temp}"

# parse GR epg
for f in $(find "${workdir}/" -type f -regex '.*\/[0-9]*\.xml$'); do
  parse_epg "${f}" "${ch_temp}" 1
done
for f in $(find "${workdir}/" -type f -regex '.*\/C[0-9]*\.xml$'); do
  parse_epg "${f}" "${ch_temp}" 2
done

# parse BS epg
for f in $(find "${workdir}/" -type f -regex '.*\/BS[0-9]*_[0-2]\.xml$'); do
  parse_epg "${f}" "${ch_temp}" 3
done

# parse CS epg
for f in $(find "${workdir}/" -type f -regex '.*\/CS[0-9]*\.xml$'); do
  parse_epg "${f}" "${ch_temp}" 4
done

# generate mirakurun config
rm -f mirakurun_ch.yml
sort < "${ch_temp}" | uniq | awk -F '|' '{
  type = "";
  if ($1 == "1" || $1 == "2") {
    type = "GR";
  } else if ($1 == "3") {
    type = "BS";
  } else if ($1 == "4") {
    type = "CS";
  }
  printf("- name: '\''%s'\''\n", $6);
  printf("  type: '\''%s'\''\n", type);
  printf("  channel: '\''%s'\''\n", $4);
  if ($1 == "3" || $1 == "4") {
    printf("  serviceId: %s\n", $5);
  }
  printf("\n");
}' >> "${CONF_MIRAKURUN}"

# generate mirakc config
rm -f mirakc_ch.yml
echo "channels:" >> mirakc_ch.yml
sort < "${ch_temp}" | uniq | awk -F '|' '{
  type = "";
  if ($1 == "1" || $1 == "2") {
    type = "GR";
  } else if ($1 == "3") {
    type = "BS";
  } else if ($1 == "4") {
    type = "CS";
  }
  printf("  - name: '\''%s'\''\n", $6);
  printf("    type: '\''%s'\''\n", type);
  printf("    channel: '\''%s'\''\n", $4);
  if ($1 == "3" || $1 == "4") {
    printf("    services: [%s]\n", $5);
  }
  printf("\n");
}' >> "${CONF_MIRAKC}"

# drop working
rm -rf "${workdir}"

echo 'channel scan done.' >&2
echo "output ${CONF_MIRAKURUN}, ${CONF_MIRAKC}" >&2
return 0
