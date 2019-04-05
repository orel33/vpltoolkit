#!/bin/bash

VNCPORT="5999"

DOCKEROPT=""
DOCKEROPT="$DOCKEROPT -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker"
# DOCKEROPT="$DOCKEROPT -v /tmp/.X11-unix:/tmp/.X11-unix:rw"
DOCKEROPT="$DOCKEROPT -p 5900:5900 -p 5901:5901 -p $VNCPORT:$VNCPORT"
DOCKEROPT="$DOCKEROPT -e USER=root -e HOME=/root -e VNCPORT=$VNCPORT"
DOCKEROPT="$DOCKEROPT -v $PWD/vncserver.sh:/vncserver.sh"
docker run -it --rm -w /root $DOCKEROPT orel33/mydebian /vncserver.sh

# vncviewer localhost:5999

# EOF

