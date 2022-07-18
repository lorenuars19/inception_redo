FROM alpine:3.15

RUN apk -U update && apk add mariadb mariadb-client

COPY ./mysql_setup.sh /setup.sh

ENTRYPOINT ["/bin/sh", "/setup.sh"]
