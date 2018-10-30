#!/bin/bash
[ $# -ne 1 -a $# -ne 2 ] && echo "⚠ Usage: $0 <exo> [<inputdir>]" && exit 0
EXO=$1
INPUTDIR=$2
RUNDIR=$(mktemp -d)
( cd $RUNDIR && git clone "https://github.com/orel33/vpltoolkit.git" &> /dev/null )
source $RUNDIR/vpltoolkit/toolkit.sh
DOWNLOAD "https://github.com/orel33/vpltoolkit.git" "demo" $EXO
START_OFFLINE $INPUTDIR
