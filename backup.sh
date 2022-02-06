#!/bin/ash
set -e -o pipefail

function doArchive() {
    if [ -z "$1" -a -d "$1" ]; then
        echo "Need to have an existing source folder as first parameter in doArchive function."
        return 1
    fi

    if ! mkdir -p "/media/backup/$BACKUP_FOLDER/$date_dir"; then
        echo "Cannot create directory /media/backup/$BACKUP_FOLDER/$date_dir"
        return 1
    fi

    echo "Creating archive."
    cd $1
    if ! tar -c -f "/media/backup/$BACKUP_FOLDER/$date_dir/$ARCHIVE_NAME.tar${COMPRESS_EXT}" $COMPRESS_PARAM . ; then
        echo "$ARCHIVE_NAME backup failed while doing rsync."
        return 1
    fi
    echo "$ARCHIVE_NAME archive created."
}

function doRsync() {
    echo "Doing rsync."
    if ! rsync --archive --delete "$SOURCE/" "$backup_rsync"; then
        echo "$ARCHIVE_NAME backup failed while doing rsync."
        return 1
    fi
    echo "rsync completed."
}

if [ $# -eq 2 ]; then
    if [ "$1" != "--rsync" -o -z "$2" ]; then
        echo echo "Only the --rsync <folder> parameter is accepted."
        exit 1
    fi
    rsync_folder=$2
elif [ $# -ne 0 ]; then
    echo "Only the --rsync <folder> parameter is accepted."
    exit 1
fi

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

if [ -n "$rsync_folder" ]; then
    backup_rsync="/media/backup/$BACKUP_FOLDER/$rsync_folder"
    if [ -d $backup_rsync ] && [ -n "$(ls $backup_rsync)" ]; then
        if doArchive "$backup_rsync" && doRsync; then
            echo "$ARCHIVE_NAME backup completed."
        else
            echo "$ARCHIVE_NAME backup failed."
        fi
    else
        echo "rsync folder does not exist or is empty. Only do rsync this time."
        if mkdir -p "$backup_rsync"; then
            if doRsync; then
                echo "$ARCHIVE_NAME backup completed."
            else
                echo "$ARCHIVE_NAME backup failed."
            fi
        else
          echo "Cannot create directory $backup_rsync"
        fi
    fi
elif doArchive "$SOURCE"; then
    echo "$ARCHIVE_NAME backup completed."
else
    echo "$ARCHIVE_NAME backup failed."
fi;
echo -e "----------------------------------------\n" 
