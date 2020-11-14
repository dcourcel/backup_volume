#!/bin/ash
set -e -o pipefail

if [ -z "$SOURCE" ]; then
    echo '$SOURCE' is not defined
    exit 1
fi;
if [ -z "$DESTINATION" ]; then
    echo '$DESTINATION' is not defined
    exit 1
fi;

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
echo "Begin $BACKUP_NAME backup."
if mkdir -p "$DESTINATION" && cd "$SOURCE" && tar -c -f "${DESTINATION}/${BACKUP_NAME}_$(date +%Y-%m-%d_%H-%M-%S).tar${COMPRESS_EXT}" $COMPRESS_PARAM . ; then
    echo "$BACKUP_NAME backup completed"
else
    echo "$BACKUP_NAME backup failed"
fi;
echo -e "----------------------------------------\n" 
