#!/bin/bash

DOCKER="orel33/mydebian"
DOCKEROPT=""
DOCKEROPT="$DOCKEROPT -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker"
DOCKEROPT="$DOCKEROPT -v /tmp/.X11-unix:/tmp/.X11-unix"
DOCKEROPT="$DOCKEROPT -e DISPLAY=$DISPLAY"
# DOCKEROPT="$DOCKEROPT --device=/dev/dri:/dev/dri"
DOCKEROPT="$DOCKEROPT -e LIBGL_ALWAYS_SOFTWARE=1"
# xhost +
docker run -it --rm  $DOCKEROPT $DOCKER

# EOF

