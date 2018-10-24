#!/bin/bash

# model
VPLMODEL="https://github.com/orel33/vplmodel.git"
MODE="EVAL"
RUNDIR=$HOME
REPOSITORY="https://github.com/orel33/vplmodel.git"
BRANCH="demo"
DEBUG=1
VERBOSE=1

git clone $VPLMODEL &> /dev/null
source $RUNDIR/vplmodel/toolkit.sh

EXO="hello"
START