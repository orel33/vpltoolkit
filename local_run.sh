#!/bin/bash
VPLMODEL="https://github.com/orel33/vplmodel.git"
MODE="RUN"
REPOSITORY="https://github.com/orel33/vplmodel.git"
BRANCH="demo"
EXO="hello"
DEBUG=1
VERBOSE=1
RUNDIR=$(mktemp -d)

cd $RUNDIR && git clone $VPLMODEL &> /dev/null && cd -
source $RUNDIR/vplmodel/toolkit.sh
START

# explicit run
source $RUNDIR/vplmodel/vpl_execution
