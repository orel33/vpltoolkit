#!/bin/bash
rm -f $0
RUNDIR=$(mktemp -d)
( cd $RUNDIR && git clone "https://github.com/orel33/vpltoolkit.git" &> /dev/null )
source $RUNDIR/vpltoolkit/start.sh
EXO="hello"
DOWNLOAD "https://github.com/orel33/vpltoolkit.git" "demo" $EXO
START_ONLINE
