#!/bin/bash

# default parameters
TIMEOUT=10
RUNDIR=$(mktemp -d)
LOCALDIR=""
REPOSITORY=""
SUBDIR=""
INPUTDIR=""
VERBOSE="0"
GRAPHIC=0
MODE=""
DOCKER="orel33/mydebian:latest"
DOCKERTIMEOUT="infinity" # default 900s
VPLTOOLKIT="https://github.com/orel33/vpltoolkit.git"
VERSION="master"    # VPL Toolkit branch
# RUNSUBDIR="$RUNDIR/$EXDIR"

### USAGE ###

USAGE() {
    echo "Usage: $0 [options] <...>"
    echo "    -m <mode>: force execution mode to RUN, DEBUG or EVAL"
    echo "    -g : enable graphic mode (default no)"
    echo "    -d <docker> : set docker image to be used (default $DOCKER)"
    echo "    -n <version> : set the branch/version of VPL Toolkit to use (default $VERSION)"
    echo "    -l <localdir>: copy files from local directory into <rundir>"
    echo "    -r <repository>: download run files from remote git repository"
    echo "    -s <subdir>: copy files from repository/subdir into <rundir>"
    echo "    -i <inputdir>: student input directory"
    echo "    -v: verbose"
    echo "    -h: help"
    exit 0
}

### PARSE ARGUMENTS ###

GETARGS() {
    while getopts "gr:l:s:i:m:d:n:vh" OPT ; do
        case $OPT in
            g)
                GRAPHIC=1
            ;;
            d)
                DOCKER="$OPTARG"
            ;;
            m)
                grep -w $OPTARG <<< "RUN DEBUG EVAL" &> /dev/null
                [ $? -ne 0 ] && echo "⚠ Error: Invalid option \"-m $OPTARG\"" >&2 && USAGE
                MODE="$OPTARG"
            ;;
            n   )
                VERSION="$OPTARG"
            ;;
            l)
                LOCALDIR="$OPTARG"
            ;;
            r)
                REPOSITORY="$OPTARG"
            ;;
            s)
                SUBDIR="$OPTARG"
            ;;
            i)
                INPUTDIR="$OPTARG"
            ;;
            v)
                VERBOSE=1
            ;;
            h)
                USAGE
            ;;
            \?)
                USAGE
            ;;
        esac
    done

    shift $((OPTIND-1))

    ARGS="$@"
}

############################################################################################
#                                           LOCAL RUN                                      #
############################################################################################

GETARGS $*

if [ $VERBOSE -eq 1 ] ; then
    echo "VPLTOOLKIT=$VPLTOOLKIT"
    echo "VERSION=$VERSION"
    echo "RUNDIR=$RUNDIR"
    echo "LOCALDIR=$LOCALDIR"
    echo "REPOSITORY=$REPOSITORY"
    echo "SUBDIR=$SUBDIR"
    echo "INPUTDIR=$INPUTDIR"
    echo "ARGS=$ARGS"
    echo "DOCKER=$DOCKER"
    echo "GRAPHIC=$GRAPHIC"
fi

### PULL DOCKER IMAGE ###

LOG="$RUNDIR/start.log"

if [ -n $DOCKER ] ; then 
    ( timeout $TIMEOUT docker pull $DOCKER ) &> $LOG
    [ $? -ne 0 ] && echo "⚠ Error: Docker fails to pull image \"$DOCKER\"!" >&2 && exit 1
fi

### DOWNLOAD VPL TOOLKIT ###

( cd $RUNDIR && timeout $TIMEOUT git clone "$VPLTOOLKIT" --depth 1 -b "$VERSION" --single-branch ) &> $LOG
[ $? -ne 0 ] && echo "⚠ Error: Git fails to clone \"$VPLTOOLKIT\"!"  >&2 && exit 1
source $RUNDIR/vpltoolkit/start.sh

### LOCALDIR ###

if [ -n "$LOCALDIR" ] ; then
    [ ! -d $LOCALDIR ] && echo "⚠ Error: invalid path \"$LOCALDIR\"!"  >&2 && exit 1
    cp -rf $LOCALDIR/* $RUNDIR/
fi

### REPOSITORY ###

if [ -n "$REPOSITORY" ] ; then
    DOWNLOAD "$REPOSITORY" "master" "$SUBDIR"
fi

START_OFFLINE "$INPUTDIR" $ARGS

# EOF
