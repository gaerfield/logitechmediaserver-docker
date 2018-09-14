# logitechmediaserver-docker
Allows to build an Docker-Image for Logitechs Media Server (aka  Squeezebox-Server)

## runtime - variables

Before starting the container using a `docker-compose.yml` (examples below):

1) find out the group-id of your files-share
On startup the container will use the group-id the get read-access to your files. This way, no recursive `chmod/chown` is needed to allow the server read_access to these files.

  * given that `ls -al /home/of/my/music` will print `-rw-rw-r-- 1 someuser somegroup music`
  * call `getent group somegroup` which will output something like `somegroup:x:1002:`
  * note the output `1002` and put this as environment-variable in the compose-file

2) three important folders (that should / could be mounted)

  * `/var/log/squeezeboxserver`: contains the log-files
  * `/var/lib/squeezeboxserver`: contains the instance-data (plugins, cache, preferences) allowing reboots of the container without loosing your preferences
  * `/mnt/music`: the location of the mount is not important (because it's configurable through the web-interface), but it should be available and readable by the group you've given as group-id

3) Once started, access it using the port 9000 (i.e. [http://localhost:9000](http://localhost:9000))

## starting the container

You could (see also [docker-compose.yml](docker-compose.yml)):

* either using the image(s) on docker hub
* or building you're own image

### Using the hub

Example `docker-compose.yml`
```
version: '2'

services:
  logitechmediaserver:
    image: gaerfield/logitechmediaserver:7.9.1
    restart: always
    ports:
      - 9000:9000
      - 9090:9090
      - 3483:3483
      - 3483:3483/udp
    environment:
      - GROUP_ID=116
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./instancedata/prefs:/var/lib/squeezeboxserver
      - ./logs:/var/log/squeezeboxserver
      - /mnt/shares/media/music:/mnt/music
```

### Building you're own image

**DOWNLOAD_URL**: The Build-Argument `DOWNLOAD_URL` is optional. Use it to choose a custom installation-package (i.e. for ARM-Devices like the [Rasperry Pi](https://www.raspberrypi.org/)). You can choose from different versions and packages in [Logitechs Download Section](http://downloads-origin.slimdevices.com/).

**image-name**: The Image-Name `image: ...` is optional. The default-name for the image depends on your compose-file (in this example it would be `logitechmediaserver:latest`).

Example `docker-compose.yml`
```
version: '2'

services:
  logitechmediaserver:
    build:
      context: https://github.com/gaerfield/logitechmediaserver-docker.git
      args: # optional
         DOWNLOAD_URL: "http://downloads-origin.slimdevices.com/LogitechMediaServer_v7.9.1/logitechmediaserver_7.9.1_amd64.deb"
    image: logitechmediaserver:7.9.1 #optional
    restart: always
    ports:
      - 9000:9000
      - 9090:9090
      - 3483:3483
      - 3483:3483/udp
    environment:
      - GROUP_ID=116
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./instancedata/prefs:/var/lib/squeezeboxserver
      - ./logs:/var/log/squeezeboxserver
      - /mnt/shares/media/music:/mnt/music
```

## Links

 * [gaerfield/logitechmediaserver](https://hub.docker.com/r/gaerfield/logitechmediaserver/): docker hub image build from this repo
 * related work:
   * [jgoerzen/docker-logitech-media-server](https://github.com/jgoerzen/docker-logitech-media-server)
   * [justifiably/docker-logitechmediaserver](https://github.com/justifiably/docker-logitechmediaserver)
   * [larsks/docker-image-logitech-media-server](https://github.com/larsks/docker-image-logitech-media-server)
 * Download Links:
   * [latest Logitech Media Server](https://www.mysqueezebox.com/download)
   * choose from different packages and versions  [here](http://downloads-origin.slimdevices.com/)
 * Documentation on LogitechMediaServer:
   * [Squeezebox Wiki](http://wiki.slimdevices.com/index.php/Main_Page)
   * [Server's file locations](http://wiki.slimdevices.com/index.php/Logitech_Media_Server_file_locations)
   * [Squeezelite](http://wiki.slimdevices.com/index.php/Squeezelite) client
