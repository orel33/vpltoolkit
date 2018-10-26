#!/bin/bash

VPLMODEL="https://github.com/orel33/vplmodel.git"
RUNDIR=$(mktemp -d)
MODE="RUN"
DEBUG=1
VERBOSE=1

( cd $RUNDIR && git clone $VPLMODEL &> /dev/null )
source $RUNDIR/vplmodel/toolkit.sh

EXO="mycat"
DOWNLOAD "https://github.com/orel33/vplmodel.git" "demo" $EXO
START_OFFLINE $1
