#!/bin/bash
[ $# -ne 2 ] && echo "⚠ Usage: $0 <exo> <inputdir>" && exit 0

EXO=$1
INPUTDIR=$2

VPLMODEL="https://github.com/orel33/vplmodel.git"
RUNDIR=$(mktemp -d)
MODE="RUN"
# DEBUG=1
# VERBOSE=1

( cd $RUNDIR && git clone $VPLMODEL &> /dev/null )
source $RUNDIR/vplmodel/toolkit.sh

DOWNLOAD "https://github.com/orel33/vplmodel.git" "demo" $EXO
START_OFFLINE $INPUTDIR
