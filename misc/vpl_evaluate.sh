#!/bin/bash
rm -f $0 # for security issue
RUNDIR=$(mktemp -d)
( cd $RUNDIR && git clone "https://github.com/orel33/vpltoolkit.git" -b "3.0" &> /dev/null )
[ ! $? -eq 0 ] && echo "⚠ Fail to download VPL Toolkit!" && exit 0
source $RUNDIR/vpltoolkit/start.sh
DOWNLOAD "https://github.com/orel33/vpltoolkit.git" "demo" "hello"
START_ONLINE
