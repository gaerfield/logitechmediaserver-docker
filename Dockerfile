FROM debian:stable-slim

ARG DOWNLOAD_URL=http://downloads-origin.slimdevices.com/LogitechMediaServer_v7.9.1/logitechmediaserver_7.9.1_amd64.deb

ENV DEBIAN_FRONTEND noninteractive
ENV LOGDIR=/var/log/squeezeboxserver
ENV INSTANCEDIR_BOOTSTRAP=/var/lib/squeezeboxserver.bootstrap
ENV INSTANCEDIR=/var/lib/squeezeboxserver

# http://www.mysqueezebox.com/update/?version=7.9.1&revision=1&geturl=1&os=deb[arm|amd64] 
#ARG PACKAGE_URL=http://www.mysqueezebox.com/update/?version=7.9.1&revision=1&geturl=1&os=deb
ARG APP_LOCALE=en_US
ARG APP_CHARSET=UTF-8

# Install Packages
RUN    apt-get update \
    && apt-get -y -u dist-upgrade \
    && apt-get -y --no-install-recommends install \
            libio-socket-ssl-perl \
            curl \
            dpkg \
            faad \
            flac \
            lame \
            locales \
            sed \
            sox \
            wavpack \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# configure locale
RUN    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i -e 's/# nb_NO.UTF-8 UTF-8/nb_NO.UTF-8 UTF-8/' /etc/locale.gen \
    && echo 'LANG="nb_NO.UTF-8"'>/etc/default/locale \
    && dpkg-reconfigure locales \
    && locale-gen ${APP_LOCALE}.${APP_CHARSET} \
    && localedef ${APP_LOCALE}.${APP_CHARSET} -i $APP_LOCALE -f $APP_CHARSET \
    && update-locale LANG=nb_NO.UTF-8 \
    && adduser --system --uid 101 --shell /bin/false squeezeboxserver

ENV LANGUAGE=${APP_LOCALE}.${APP_CHARSET}
ENV LANG=${APP_LOCALE}.${APP_CHARSET}
ENV LC_CTYPE=${APP_LOCALE}.${APP_CHARSET}
ENV LC_ALL=${APP_LOCALE}.${APP_CHARSET}

# download and install squeezebox
RUN    curl -Lsf -o /tmp/lms.deb $DOWNLOAD_URL \
    && dpkg -i /tmp/lms.deb \
    && rm -f /tmp/lms.deb \
    && apt-get clean

# moving instance-directories to another folder for bootstraping
# because of this, we can mount the instance-directories
RUN mv $INSTANCEDIR $INSTANCEDIR_BOOTSTRAP

VOLUME ["$INSTANCEDIR", "$LOGDIR", "/mnt"]

EXPOSE 3483 3483/udp 9000 9090

COPY ./docker-entrypoint.sh /
CMD ["/docker-entrypoint.sh"]
