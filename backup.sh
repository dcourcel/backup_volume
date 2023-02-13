#!/bin/ash
set -e -o pipefail

function doArchive() {
    if [ "$1" == "--rsync" ]; then
      source_folder="$2"
    else
      source_folder="$1"
    fi

    if [ -z "$source_folder" -a -d "$source_folder" ]; then
        echo "Need to have an existing source folder as parameter in doArchive function."
        return 1
    fi

    cd $source_folder
    if [ "$1" == "--rsync" ]; then
        if [ ! -f "date" -o ! -d content ]; then
            echo "No date file or content folder. Failing back to date_dir"
            date_from_file="$date_dir-prev"
        else
            date_from_file=$(cat date)
            cd content
        fi
    else
        date_from_file="$date_dir"
    fi

    if ! mkdir -p "/media/backup/$BACKUP_FOLDER/$date_from_file"; then
        echo "Cannot create directory /media/backup/$BACKUP_FOLDER/$date_from_file"
        return 1
    fi

    echo "Creating archive."
    if ! tar -c -f "/media/backup/$BACKUP_FOLDER/$date_from_file/$ARCHIVE_NAME.tar${COMPRESS_EXT}" $COMPRESS_PARAM . ; then
        echo "$ARCHIVE_NAME backup failed while doing rsync."
        return 1
    fi
    echo "$ARCHIVE_NAME archive created."
}

function doRsync() {
    echo "Doing rsync."
    if ! echo "$date_dir" > "$backup_rsync/date"; then
        echo "Failed to write date inside $backup_rsync/date"
        return 1
    fi
    if ! rsync --archive --delete "$SOURCE/" "$backup_rsync/content"; then
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
        if doArchive "--rsync" "$backup_rsync" && doRsync; then
            echo "$ARCHIVE_NAME backup completed."
        else
            echo "$ARCHIVE_NAME backup failed."
        fi
    else
        echo "rsync folder does not exist or is empty. Only do rsync this time."
        if mkdir -p "$backup_rsync/content"; then
            if doRsync; then
                echo "$ARCHIVE_NAME backup completed."
            else
                echo "$ARCHIVE_NAME backup failed."
            fi
        else
            echo "Cannot create directory $backup_rsync/content"
        fi
    fi
elif doArchive "$SOURCE"; then
    echo "$ARCHIVE_NAME backup completed."
else
    echo "$ARCHIVE_NAME backup failed."
fi;
echo -e "----------------------------------------\n" 
