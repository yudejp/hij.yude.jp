FROM ghcr.io/yude/docker-softether-vpn-client:master

RUN apt update; apt -y upgrade
RUN apt -y install ethtool ifupdown lsof

COPY ./nic-up.bash /usr/local/bin/nic-up
RUN chmod +x /usr/local/bin/nic-up

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
