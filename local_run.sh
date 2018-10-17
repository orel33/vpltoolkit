#!/bin/bash
VPLMODEL="https://github.com/orel33/vplmodel.git"
MODE="RUN"
REPOSITORY="https://github.com/orel33/vplmodel.git"
BRANCH="demo"
EXO="hello"
DEBUG=1
VERBOSE=1
# RUNDIR=$HOME
# RUNDIR=$(dirname $(realpath $0))
RUNDIR=$(mktemp -d)

cd $RUNDIR && git clone $VPLMODEL &> /dev/null && cd -
source $RUNDIR/vplmodel/vplmodel.sh
vplmodel_start

# explicit run
source $RUNDIR/vplmodel/vpl_execution
