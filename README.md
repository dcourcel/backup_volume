# Docker image to backup a Docker volume
This image creates a .tar.bz2 file from the content of a docker volume. The destination of the file is /media/backup/$BACKUP_FOLDER/$(date +%Y-%m-%d\_%H-%M-%S) with the name $ARCHIVE_NAME.tar{.compression}.

The following table describe the environment variables to specify. The variables without a default value must be specified.
| Variable     | Description                                                                                         | Default       |
| ------------ | --------------------------------------------------------------------------------------------------- | ------------- |
| SOURCE       | The archive is created with the content of the folder specified by this variable.                   | /media/volume |
| BACKUP_FOLDER| The name of the folder inside /media/backup to create the date folder and to put the archive files. |               |
| ARCHIVE_NAME | The name of the archive to create. The file suffix depends of the compression parameter. The file name will be in the format ${ARCHIVE_NAME}.tar{.compression} | |
| DATE_DIR_FILE| The file path containing the name of the folder to look for ARCHIVE_NAME.                           |               |
| COMPRESSION  | The compression type to use. Valid values are 'tar' (to indicate no compression), 'gz' or 'bz2'.    | bz2           |

# Example of execution
> docker run --mount type=volume,src=_my_volume_,dst=/media/volume --mount type=volume,src=_backup_,dst=/media/backup --env BACKUP_FOLDER=_my\_backup_ --env ARCHIVE_NAME=_my\_archive_ --env COMPRESSION=gz

Note that you can create a volume referencing another hard drive with the following options (and you can specify a drive uuid instead with the path /dev/disk/by-uuid/):
> docker volume create -o type=_ext4_,device=_/dev/sdb1_ backup
