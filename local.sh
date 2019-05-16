#!/usr/bin/env bash

# default parameters
RUNDIR=$(mktemp -d)
LOCALDIR=""
REPOSITORY=""
BRANCH="master"
PASSWORD=""
URL=""
SUBDIR=""
INPUTDIR=""
VERBOSE=0
GRAPHIC=0
MODE="RUN"
DOCKER=""
DOCKERTIMEOUT="1h"  # 1 hour
VPLTOOLKIT="https://github.com/orel33/vpltoolkit.git"
LOCAL=0
DEBUG=0
VERSION="master"    # VPL Toolkit branch
ENTRYPOINT="run.sh"
DOWNLOAD=0

### USAGE ###

USAGE() {
    echo "Usage: $0 <download> [options] <...>"
    echo "Start VPL Toolkit on localhost."
    echo "select <download> method:"
    echo "    -l <localdir>: copy teacher files from local directory into <rundir>"
    echo "    -r <repository>: download teacher files from remote git repository"
    echo "    -w <url>: download teacher zip archive from remote web site"
    echo "[options]:"
    echo "    -L: use local version of VPL Toolkit"
    echo "    -n <version> : set the branch/version of VPL Toolkit to use (default $VERSION)"
    echo "    -m <mode>: set execution mode to RUN, DEBUG or EVAL (default $MODE)"
    echo "    -g : enable graphic mode (default no)"
    echo "    -d <docker> : set docker image to be used (default, no docker)"
    echo "    -b <branch>: checkout a branch from git repository (default $BRANCH, -r required)"
    echo "    -p <password>: unzip teacher archive using a password (-w required)"
    echo "    -s <subdir>: only download teacher files from subdir into <rundir>"
    echo "    -e <entrypoint>: entrypoint shell script (default $ENTRYPOINT)"
    echo "    -i <inputdir>: student input directory"
    echo "    -v: enable verbose mode (default no)"
    echo "    -D: enable debug mode (default no)"
    echo "    -h: help"
    echo "<...>: extra arguments passed to START routine in VPL Toolkit"
    exit 0
}

### PARSE ARGUMENTS ###

GETARGS() {
    while getopts "gr:w:l:s:i:m:d:n:b:p:e:DLvh" OPT ; do
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
                ((DOWNLOAD++))
                LOCALDIR="$OPTARG"
            ;;
            r)
                ((DOWNLOAD++))
                REPOSITORY="$OPTARG"
            ;;
            w)
                ((DOWNLOAD++))
                URL="$OPTARG"
            ;;
            b)
                BRANCH="$OPTARG"    # FIXME: -r required
            ;;
            p)
                PASSWORD="$OPTARG"  # FIXME: -w required
            ;;
            s)
                SUBDIR="$OPTARG"
            ;;
            i)
                INPUTDIR="$OPTARG"
            ;;
            e)
                ENTRYPOINT="$OPTARG"
            ;;
            L)
                LOCAL=1
            ;;
            D)
                DEBUG=1
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

    [ $DOWNLOAD -eq 0 ] && USAGE
    [ $DOWNLOAD -gt 1 ] && echo "⚠ Error: select only one download method!" >&2 && USAGE
    [ $LOCAL -eq 1 -a "$VERSION" != "master" ] && echo "⚠ Warning: option -n <version> is ignored!" >&2
    shift $((OPTIND-1))
    ARGS="$@"
}

############################################################################################
#                                           LOCAL RUN                                      #
############################################################################################

GETARGS $*

if [ $VERBOSE -eq 1 ] ; then
    echo "VPLTOOLKIT=$VPLTOOLKIT"
    echo "LOCAL=$LOCAL"
    echo "VERSION=$VERSION"
    echo "RUNDIR=$RUNDIR"
    echo "LOCALDIR=$LOCALDIR"
    echo "REPOSITORY=$REPOSITORY"
    echo "BRANCH=$BRANCH"
    echo "URL=$URL"
    echo "SUBDIR=$SUBDIR"
    echo "INPUTDIR=$INPUTDIR"
    echo "ARGS=$ARGS"
    echo "DOCKER=$DOCKER"
    echo "GRAPHIC=$GRAPHIC"
    echo "ENTRYPOINT=$ENTRYPOINT"
    echo "VERBOSE=$VERBOSE"
    echo "DEBUG=$DEBUG"
fi

### PULL DOCKER IMAGE ###

TIMEOUT=10
LOG="$RUNDIR/start.log"

if [ -n "$DOCKER" ] ; then 
    # [ -z $(docker images -q $DOCKER) ] && "⚠ Error: Docker image \"$DOCKER\" not found... please, pull it!" >&2 && exit 1
    # timeout $TIMEOUT docker pull $DOCKER
    if [ $VERBOSE -eq 1 ] ; then
        docker pull $DOCKER
    else
        docker pull $DOCKER &>> $LOG
    fi
    RET=$?
    [ $RET -eq 124 ] && echo "⚠ Error: pulling docker image \"$DOCKER\" (timeout)!" >&2 && exit 1
    [ $RET -ne 0 ] && echo "⚠ Error: pulling docker image \"$DOCKER\" (failure)!" >&2 && exit 1
fi

### DOWNLOAD VPL TOOLKIT ###

if [ $LOCAL -eq 0 ] ; then
    ( cd $RUNDIR && timeout $TIMEOUT git clone "$VPLTOOLKIT" --depth 1 -b "$VERSION" --single-branch ) &>> $LOG
    [ $? -ne 0 ] && echo "⚠ Error: Git fails to clone \"$VPLTOOLKIT\" (branch $VERSION)!" >&2 && exit 1
else
    VPLDIR="$(realpath $(dirname $0))"
    [ ! -d "$VPLDIR" ] && echo "⚠ Error: invalid local VPL Toolkit directory  \"$VPLDIR\"!" >&2 && exit 1
    mkdir -p $RUNDIR/vpltoolkit && cp -rf $VPLDIR/* $RUNDIR/vpltoolkit/
fi

source $RUNDIR/vpltoolkit/start.sh || exit 1

### LOCAL ###

if [ -n "$LOCALDIR" ] ; then
    SRCDIR="$LOCALDIR"
    [ -n "$SUBDIR" ] && SRCDIR="$LOCALDIR/$SUBDIR"
    [ ! -d $SRCDIR ] && echo "⚠ Error: invalid path \"$SRCDIR\"!" >&2 && exit 1
    cp -rf $SRCDIR/. $RUNDIR/ &>> $LOG
fi

### REPOSITORY ###

if [ -n "$REPOSITORY" ] ; then
    DOWNLOAD "$REPOSITORY" "$BRANCH" "$SUBDIR"
fi

### WEB ###

if [ -n "$URL" ] ; then
    WGET "$URL" "$SUBDIR" "$PASSWORD"
fi

### START ###

START_OFFLINE "$INPUTDIR" $ARGS

# EOF
