#!/bin/bash
ONLINE=1
MODE="RUN"
DEBUG=1
VERBOSE=1
RUNDIR=$(mktemp -d)

( cd $RUNDIR && git clone "https://github.com/orel33/vpltoolkit.git" &> /dev/null )
source $RUNDIR/vpltoolkit/toolkit.sh

EXO="hello"
DOWNLOAD "https://github.com/orel33/vpltoolkit.git" "demo" $EXO
START
