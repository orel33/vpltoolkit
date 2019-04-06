#!/bin/bash

VNCPORT="5999"

# https://www.digitalocean.com/community/tutorials/how-to-share-data-between-docker-containers
docker volume create --name x11-unix-volume

DOCKEROPT=""
DOCKEROPT="$DOCKEROPT -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker"
DOCKEROPT="$DOCKEROPT -v x11-unix-volume:/tmp/.X11-unix"        # share data volume
# DOCKEROPT="$DOCKEROPT -v /tmp/.X11-unix:/tmp/.X11-unix:rw"    # mount host dir
DOCKEROPT="$DOCKEROPT -p $VNCPORT:$VNCPORT" # -p 5900:5900 -p 5901:5901
DOCKEROPT="$DOCKEROPT -e USER=root -e HOME=/root -e VNCPORT=$VNCPORT"
DOCKEROPT="$DOCKEROPT -v $PWD/vncserver.sh:/vncserver.sh"
docker run -it --rm -w /root $DOCKEROPT orel33/mydebian /vncserver.sh

# vncviewer localhost:5999

# docker volume ls
docker volume rm x11-unix-volume

# EOF

