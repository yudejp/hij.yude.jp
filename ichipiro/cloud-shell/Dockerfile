FROM ubuntu:22.04 as runner

# Install base packages
RUN apt -y update; apt -y upgrade
RUN apt -y install openssh-server build-essential curl supervisor nano vim iputils-ping neofetch git ipython3

# Install Rust toolchain
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Setup Cloudflare WARP
RUN curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
RUN apt update; apt -y install cloudflare-warp

# Setup openssh-server
EXPOSE 22
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#?PermitEmptyPasswords\s+.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#?UsePAM\s+.*/UsePAM no/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN mkdir -p /run/sshd
RUN passwd -d root

# Reflect our motd
RUN sed '/motd.dynamic/d' -i /etc/pam.d/login
COPY ./motd /etc/motd

# Setup supervisord
COPY ./supervisord.conf /etc/supervisord.conf
COPY ./bashrc /root/.bashrc

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
