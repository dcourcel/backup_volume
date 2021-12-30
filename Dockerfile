FROM alpine:latest

RUN apk add rsync

ENV SOURCE=/media/volume
ENV DESTINATION=/media/backup
ENV BACKUP_FOLDER=
ENV DATE_DIR_FILE=

WORKDIR /

COPY backup.sh backup.sh

ENTRYPOINT ["/backup.sh"]
