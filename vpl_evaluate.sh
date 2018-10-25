#!/bin/bash
VPLMODEL="https://github.com/orel33/vplmodel.git"
ONLINE=1
MODE="EVAL"
DEBUG=1
VERBOSE=1
RUNDIR=$(mktemp -d)

( cd $RUNDIR && git clone $VPLMODEL &> /dev/null )
source $RUNDIR/vplmodel/toolkit.sh

EXO="hello"
DOWNLOAD "https://github.com/orel33/vplmodel.git" "demo" $EXO
START
