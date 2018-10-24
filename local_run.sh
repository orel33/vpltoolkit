#!/bin/bash
VPLMODEL="https://github.com/orel33/vplmodel.git"
MODE="RUN"
# REPOSITORY="https://github.com/orel33/vplmodel.git"
# BRANCH="demo"
EXO="hello"
DEBUG=1
VERBOSE=1
RUNDIR=$(mktemp -d)

cd $RUNDIR && git clone $VPLMODEL &> /dev/null && cd -
source $RUNDIR/vplmodel/toolkit.sh

DOWNLOAD "https://github.com/orel33/vplmodel.git" "demo" "hello"
START

# explicit run of vpl_execution
source $RUNDIR/vplmodel/vpl_execution
