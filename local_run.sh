#!/bin/bash
[ $# -ge 2 ] && echo "⚠ Usage: $0 <exo> <inputdir> <...>" && exit 0
EXO=$1 # GIT SUBDIR
INPUTDIR=$2
ARGS="${@:3}"
TKGIT="https://github.com/orel33/vpltoolkit.git"
TKBRANCH="master"
RUNDIR=$(mktemp -d)
echo "RUNDIR=$RUNDIR"
( cd $RUNDIR && git clone $TKGIT -b $TKBRANCH &> /dev/null )
source $RUNDIR/vpltoolkit/start.sh
DOWNLOAD "https://github.com/orel33/vpltoolkit.git" "demo" $EXO
START_OFFLINE $INPUTDIR  $ARGS
