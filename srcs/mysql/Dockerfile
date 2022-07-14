FROM alpine:3.16

RUN apk -U update && apk add mysql mysql-client

COPY ./mysql_setup.sh /setup.sh

ENTRYPOINT ["/bin/sh", "/setup.sh"]
