#!/bin/bash
MODE="RUN"
RUNDIR=$(mktemp -d)
( cd $RUNDIR && git clone "https://github.com/orel33/vpltoolkit.git" &> /dev/null )
source $RUNDIR/vpltoolkit/toolkit.sh
EXO="hello"
DOWNLOAD "https://github.com/orel33/vpltoolkit.git" "demo" $EXO
START_ONLINE
