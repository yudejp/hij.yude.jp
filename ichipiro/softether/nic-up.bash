#!/bin/bash

function check_eth {
    set -o pipefail # optional.
    /sbin/ethtool "$1" | grep -q "Link detected: yes"
}

while true;
do
    if check_eth vpn_vpn; then
        ifup vpn_vpn
        break
    fi
    sleep 5
done

sleep infinity
