FROM alpine:latest

RUN set -eux \
 && apk add --no-cache \
      ccid \
      musl \
      pcsc-lite-libs \
      socat \
      tzdata \
 && apk add --no-cache --virtual .build-deps \
      gcc \
      g++\
      make \
      musl-dev \
      nodejs \
      npm \
      pcsc-lite-dev \
      pkgconf \
 # Use arib-b25-stream-test instead of stz2012/libarib25.
 # Because stz2012/libarib25 doesn't support STDIN/STDOUT.
 # stz2012/libarib25 supports NEON, but it doesn't improve the performance
 # significantly.
 && (cd /tmp; npm i arib-b25-stream-test) \
 && cp /tmp/node_modules/.bin/arib-b25-stream-test /usr/local/bin/b25 \
 # cleanup
 && apk del --purge .build-deps \
 && rm -rf /tmp/*

COPY b25-server /usr/local/bin/

EXPOSE 40773
ENTRYPOINT ["b25-server"]
