FROM l3tnun/epgstation:debian

RUN apt update; apt -y install curl build-essential
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH $HOME/.cargo/bin:$PATH
RUN $HOME/.cargo/bin/cargo install epgs-to-discord

ENTRYPOINT ["npm"]
CMD ["start"]
