FROM alpine:latest
ENV SOURCE=/media/volume
ENV DESTINATION=/media/backup
ENV BACKUP_NAME=

WORKDIR /

COPY backup.sh backup.sh

ENTRYPOINT ["/bin/ash", "-c"]

CMD ["/backup.sh"]
