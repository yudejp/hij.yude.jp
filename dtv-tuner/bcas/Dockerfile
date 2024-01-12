FROM alpine:latest

RUN set -eux \
 && apk add --no-cache \
      ccid \
      musl \
      pcsc-lite-libs \
      socat \
      tzdata

COPY bcas-server /usr/local/bin/

EXPOSE 40774
ENTRYPOINT ["bcas-server"]
