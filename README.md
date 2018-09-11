# logitechmediaserver-docker
Allows to build an Docker-Image for Logitechs Media Server / Squeezebox-Server

## Build Image

* change into imageBuild-Folder
* call `docker build -t logitechmediaserver:7.9.1 .`
* edit the dockerfile to for do

## run the image

* use the `docker-compose.yml`-file
* access it through the port 9000 (i.e. [http://localhost:9000](http://localhost:9000))
* find out the group-id of your files-share
  * given that `ls -al /home/of/my/music` will print `-rw-rw-r-- 1 someuser somegroup music`
  * call `getent group somegroup` which will output something like `somegroup:x:1002:`
  * note the output `1002` and put this as environment-variable in the compose-file
  * with the first startup a group with this group-id is created within the container, granting the container read-access for this folder without any need of recursively changing the ACL's
* 3 important folders (that should / could be mounted)
  * `/var/log/squeezeboxserver`: contains the log-files
  * `/var/lib/squeezeboxserver`: contains the instance-data (plugins, cache, preferences) allowing reboots of the container without loosing your preferences
  * `/mnt/music`: the location of the mount is not important (because it's configurable through the web-interface), but it should be available and readable by the group you've given as group-id

## Links

 * [docker hub](https://hub.docker.com/r/gaerfield/logitechmediaserver/)
 * [jgoerzen/docker-logitech-media-server](https://github.com/jgoerzen/docker-logitech-media-server)
 * [justifiably/docker-logitechmediaserver](https://github.com/justifiably/docker-logitechmediaserver)
 * [larsks/docker-image-logitech-media-server](https://github.com/larsks/docker-image-logitech-media-server)
 * [Squeezelite](http://wiki.slimdevices.com/index.php/Squeezelite)
 * [Logitech Media Server](https://www.mysqueezebox.com/download)
 * [Server's file locations](http://wiki.slimdevices.com/index.php/Logitech_Media_Server_file_locations)
