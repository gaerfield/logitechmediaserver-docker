#!/bin/bash
#
#   Initialize logitechmediaserver / squeezebox-server instance in a Docker container
#   author: garfield

GID="${GROUP_ID:-101}"

# the following environment-variables should have been set by the Dockerfile
# ENV LOGDIR=/var/log/squeezeboxserver
# INSTANCEDIR_BOOTSTRAP=/var/lib/squeezeboxserver.bootstrap
# INSTANCEDIR=/var/lib/squeezeboxserver

function log_info {
  echo -e $(date '+%Y-%m-%d %T')"\e[1;32m $@\e[0m"
}

function log_error {
  echo -e >&2 $(date +"%Y-%m-%d %T")"\e[1;31m $@\e[0m"
}

function ensure_InstanceDir {
  if [ ! -d "$LOGDIR/prefs" ]; then
    log_info "bootstrapping instance data directory $INSTANCEDIR"
    cp -r $INSTANCEDIR_BOOTSTRAP $INSTANCEDIR
    chown -R squeezeboxserver:squeezeboxserver $INSTANCEDIR
    chown -R squeezeboxserver:squeezeboxserver $LOGDIR
  fi
}

function ensure_Group {
  log_info "check for group squeezeboxserver"
  if [ -z $(getent group squeezeboxserver) ]; then
    log_info "create group 'squeezboxserver' with gid '$GID'"
    groupadd -g $GID squeezeboxserver
    log_info "adding user 'squeezboxserver' to new group 'squeezeboxserver'"
    usermod -a -G squeezeboxserver squeezeboxserver
  fi
}

function server_start {
  log_info "starting server"
  /etc/init.d/logitechmediaserver start
  log_info "server is running"
}

function server_stop {
  log_info "shutting down"
  /etc/init.d/logitechmediaserver stop  
  log_info "server is down"
  exit 0 # finally exit main handler script
}

## graceful shutdown
trap "server_stop"  SIGTERM

## bootstrapping
ensure_Group
ensure_InstanceDir

server_start
tail -F /var/log/squeezeboxserver/server.log # keep the container running

