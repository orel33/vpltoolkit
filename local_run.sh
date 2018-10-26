#!/bin/bash
VPLMODEL="https://github.com/orel33/vplmodel.git"
ONLINE=0
MODE="RUN"
DEBUG=1
VERBOSE=1
RUNDIR=$(mktemp -d)

( cd $RUNDIR && git clone $VPLMODEL &> /dev/null )
source $RUNDIR/vplmodel/toolkit.sh

EXO="mycat"
DOWNLOAD "https://github.com/orel33/vplmodel.git" "demo" $EXO
START_OFFLINE $1
