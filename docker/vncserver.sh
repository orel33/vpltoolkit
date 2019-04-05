#!/bin/bash 

VNCPW="totototo"
echo "VNCPW=$VNCPW"
echo "VNCPORT=$VNCPORT"
mkdir -p /root/.vnc
printf "$VNCPW\n$VNCPW\n" | vncpasswd -f > /root/.vnc/passwd
chmod 0600 /root/.vnc/passwd
export DISPLAY=:$VNCPORT
VNCOPT="-economictranslate -lazytight -depth 16 -nevershared -geometry 800x600 -name docker/vnc"
# FIXME: -localhost fail, because of IPV6/IPV4 problem?
nohup vncserver $DISPLAY -rfbport $VNCPORT $VNCOPT
bash
vncserver -kill $DISPLAY


