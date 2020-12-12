#!/bin/ash
set -e -o pipefail

if [ -z "$SOURCE" ]; then
    echo '$SOURCE' is not defined
    exit 1
fi;
if [ -z "$ARCHIVE_NAME" ]; then
    echo '$ARCHIVE_NAME' is not defined
    exit 1
fi;
if [ -z "$BACKUP_FOLDER" ]; then
    echo '$BACKUP_FOLDER' is not defined
    exit 1
fi;
if [ -n "$DATE_DIR_FILE" ]; then
    if [ ! -f "$DATE_DIR_FILE" ]; then
        echo "\$DATE_DIR_FILE ($DATE_DIR_FILE) is not a file."
        exit 1
    fi
    date_dir=$(head -n 1 $DATE_DIR_FILE)
    if [ -z "$date_dir" ]; then
        echo "The file $DATE_DIR_FILE is empty."
        exit 1
    fi
else
    date_dir=$(date +%Y-%m-%d_%H-%M-%S)
fi;
if ! mkdir -p /media/backup/$BACKUP_FOLDER/$date_dir; then
    echo "Cannot create directory /media/backup/$BACKUP_FOLDER/$date_dir"
    exit 1
fi

if [ -z "$COMPRESSION" -o "$COMPRESSION" = "bz2" ]; then
    COMPRESS_PARAM=-j
    COMPRESS_EXT=.bz2
elif [ "$COMPRESSION" = "gz" ]; then
    COMPRESS_PARAM=-z
    COMPRESS_EXT=.gz
elif [ "$COMPRESSION" = "tar" ]; then
    COMPRESS_PARAM=
    COMPRESS_EXT=
else
    echo "Invalid compression parameter '$COMPRESSION'."
    exit 1
fi;

echo "----------------------------------------"
echo "Begin $ARCHIVE_NAME backup."
BACKUP_FILE=/media/backup/$BACKUP_FOLDER/$date_dir/$ARCHIVE_NAME.tar${COMPRESS_EXT} &&
if cd "$SOURCE" && tar -c -f "$BACKUP_FILE" $COMPRESS_PARAM . ; then
    echo "$ARCHIVE_NAME backup completed"
else
    echo "$ARCHIVE_NAME backup failed"
fi;
echo -e "----------------------------------------\n" 
