#!/bin/bash

# launch a second docker that share the same X11 display...
# docker1$ lxterminal &          # expose VNC port 5999
# docker2$ lxterminal &          # share /tmp/.X11-unix using data volume
# host$ vncviewer localhost:5999 # connec VNC port and see two terminals!

VNCPORT="5999"
DOCKEROPT=""
DOCKEROPT="$DOCKEROPT -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker"
DOCKEROPT="$DOCKEROPT -v x11-unix-volume:/tmp/.X11-unix"        # share data volume
# DOCKEROPT="$DOCKEROPT -v /tmp/.X11-unix:/tmp/.X11-unix:rw"    # mount host dir
DOCKEROPT="$DOCKEROPT -e USER=root -e HOME=/root"
DOCKEROPT="$DOCKEROPT -e DISPLAY=:$VNCPORT -e VNCPORT=$VNCPORT"
docker run -it --rm -w /root $DOCKEROPT orel33/mydebian bash

# EOF

