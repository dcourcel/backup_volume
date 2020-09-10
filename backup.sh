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
echo "----------------------------------------"
echo "Begin $BACKUP_NAME backup."
mkdir -p "$DESTINATION" && cd "$SOURCE" && tar -c -f "${DESTINATION}/${BACKUP_NAME}_$(date +%Y-%m-%d_%H-%M-%S).tar.bz2" -j .
echo "$BACKUP_NAME backup completed"
echo -e "----------------------------------------\n" 
