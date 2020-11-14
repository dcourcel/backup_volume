# Docker image to backup a Docker volume
This image creates a .tar.bz2 file from the content of a docker volume. The source, destination and prefix name of the archive can be specified. The destination file contains the creation data in its name.

The following table describe the environment variables to specify. The variables without a default value must be specified.
| Variable     | Description                                                                                         | Default       |
| ------------ | --------------------------------------------------------------------------------------------------- | ------------- |
| SOURCE       | The archive is created with the content of the folder specified by this variable.                   | /media/volume |
| DESTINATION  | The destination folder where to create the archive file. The folder is created if it doesn't exist. | /media/backup |
| BACKUP_NAME  | The prefix used in the file created. The file name created depends also of the compression parameter, but it will be in the format ${BACKUP_NAME}\_$(date +%Y-%m-%d\_%H-%M-%S).tar{.compression} | |
| COMPRESSION  | The compression type to use. Valid values are 'tar' (to indicate no compression), 'gz' or 'bz2'           | bz2           |

# Example of execution
> docker run --mount type=volume,src=_my_volume_,dst=/media/volume --mount type=volume,src=_backup_,dst=/media/backup --env BACKUP_NAME=_my_backup_ --env COMPRESSION=gz

Note that you can create a volume referencing another hard drive with the following options (and you can specify a drive uuid instead with the path /dev/disk/by-uuid/):
> docker volume create -o type=_ext4_,device=_/dev/sdb1_ backup
