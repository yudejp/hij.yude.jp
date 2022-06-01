FROM alpine

ADD ./motd /etc/motd

RUN apk add --no-cache openssh curl && \
    mkdir /var/run/sshd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    ssh-keygen -A && \
    curl https://github.com/yude.keys >> /root/authorized_keys && \
    curl https://github.com/pepepper.keys >> /root/authorized_keys

EXPOSE 22

CMD mkdir -p ~/.ssh && \
    mv ~/authorized_keys ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys &&  \
    /usr/sbin/sshd -D