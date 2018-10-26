#!/bin/bash

VERSION="1.0"

### BASIC ROUTINES ###

ECHO()
{
    local COMMENT=""
    if [ "$MODE" = "EVALUATE" ] ; then COMMENT="Comment :=>>" ; fi
    echo "${COMMENT}$@"
}

ECHOV()
{
    if [ "$VERBOSE" = "1" ] ; then ECHO $@ ; fi
}

ECHOD()
{
    if [ "$DEBUG" = "1" ] ; then ECHO $@ ; fi
}

TRACE()
{
    if [ "$DEBUG" = "1" ] ; then
        echo "+ $@"
        bash -c "$@"
        elif [ "$VERBOSE" = "1" ] ; then
        bash -c "$@"
    else
        bash -c "$@" &> /dev/null
    fi
}

CHECK()
{
    for FILE in "$@" ; do
        [ ! -f $FILE ] && ECHO "⚠ File \"$FILE\" is missing!" && exit 0
    done
}

EXIT()
{
    (( GRADE < 0 )) && GRADE=0
    (( GRADE > 100 )) && GRADE=100
    ECHO "-GRADE" && ECHO "$GRADE / 100"
    if [ "$MODE" = "EVALUATE" ] ; then echo "Grade :=>> $GRADE" ; fi
    if [ "$MODE" = "RUN" ] ; then echo "Use Ctrl+Shift+⇧ / Ctrl+Shift+⇩ to scroll up / down..." ; fi
    exit 0
}

### ENVIRONMENT ###

function CHECKENV()
{
    # basic environment
    [ -z "$VERSION" ] && echo "⚠ VERSION variable is not defined!" && exit 0
    [ -z "$ONLINE" ] && echo "⚠ ONLINE variable is not defined!" && exit 0
    [ -z "$MODE" ] && echo "⚠ MODE variable is not defined!" && exit 0
    [ -z "$EXO" ] && echo "⚠ EXO variable is not defined!" && exit 0
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    [ -z "$DEBUG" ] && DEBUG=0
    [ -z "$VERBOSE" ] && VERBOSE=0
    [ -z "$INPUTS" ] && INPUTS=""
}

function SAVEENV()
{
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    rm -f $RUNDIR/env.sh
    echo "VERSION=$VERSION" >> $RUNDIR/env.sh
    echo "MODE=$MODE" >> $RUNDIR/env.sh
    echo "ONLINE=$ONLINE" >> $RUNDIR/env.sh
    echo "EXO=$EXO" >> $RUNDIR/env.sh
    echo "RUNDIR=$RUNDIR" >> $RUNDIR/env.sh
    echo "DEBUG=$DEBUG" >> $RUNDIR/env.sh
    echo "VERBOSE=$VERBOSE" >> $RUNDIR/env.sh
    echo "INPUTS=$INPUTS" >> $RUNDIR/env.sh
}

function LOADENV()
{
    if [ -f $RUNDIR/env.sh ] ; then
        source $RUNDIR/env.sh
    elif [ -f ./env.sh ] ; then
        source ./env.sh
    elif [ -f $HOME/env.sh ] ; then
        source $HOME/env.sh
    else
        echo "⚠ File \"env.sh\" is missing!" && exit 0
    fi
}

function PRINTENV()
{
    ECHOV "VERSION=$VERSION"
    ECHOV "ONLINE=$ONLINE"
    ECHOV "MODE=$MODE"
    ECHOV "EXO=$EXO"
    ECHOV "RUNDIR=$RUNDIR"
    ECHOV "DEBUG=$DEBUG"
    ECHOV "VERBOSE=$VERBOSE"
    ECHOV "INPUTS=$INPUTS"
}

### DOWNLOAD ###

# TODO: add wget method

function DOWNLOAD() {
    local REPOSITORY=$1
    local BRANCH=$2
    local SUBDIR=$3
    START=$(date +%s.%N)
    mkdir -p $RUNDIR/download
    [ -z "$REPOSITORY" ] && echo "⚠ REPOSITORY variable is not defined!" && exit 0
    [ -z "$BRANCH" ] && echo "⚠ BRANCH variable is not defined!" && exit 0
    [ -z "$SUBDIR" ] && echo "⚠ SUBDIR variable is not defined!" && exit 0
    git -c http.sslVerify=false clone -q -n $REPOSITORY --branch $BRANCH --depth 1 $RUNDIR/download &> /dev/null
    [ ! $? -eq 0 ] && echo "⚠ GIT clone repository failure!" && exit 0
    ( cd $RUNDIR/download && git -c http.sslVerify=false checkout HEAD -- $SUBDIR &> /dev/null )
    [ ! $? -eq 0 ] && echo "⚠ GIT checkout subdir failure!" && exit 0
    [ ! -d $RUNDIR/download/$SUBDIR ] && ECHO "⚠ SUBDIR \"$SUBDIR\" is missing!" && exit 0
    END=$(date +%s.%N)
    TIME=$(python -c "print(int(($END-$START)*1E3))") # in ms
    ECHOV "Download \"$SUBDIR\" in $TIME ms"
    cp -rf $RUNDIR/download/$SUBDIR/* $RUNDIR/
    # rm -rf $RUNDIR/download
    # ls -lR $RUNDIR
}

### COPY INPUTS ###

function COPYINPUTS() {
    ECHOV "INPUTS=\"$@\""
    mkdir -p $RUNDIR/inputs
    for FILE in "$@" ; do
        [ ! -f $FILE ] && ECHO "⚠ Input file \"$FILE\" is missing!" && exit 0
        cp $FILE $RUNDIR/inputs/
    done
}

### EXECUTION ###

function START_ONLINE() {
    source $HOME/vpl_environment.sh
    COPYINPUTS $VPL_SUBFILES
    cp $RUNDIR/env.sh $HOME
    cp $RUNDIR/vplmodel/toolkit.sh $HOME
    cp $RUNDIR/vplmodel/vpl_execution $HOME
    INPUTS=$(ls inputs/*)
    PRINTENV
    SAVEENV
    # => implicit run of $vpl_execution
}


function START_OFFLINE() {
    echo $#
    [ $# -ne 2 ] && echo "⚠ Usage: START_OFFLINE INPUTDIR" && exit 0
    local INPUTDIR=$1
    [ -z $INPUTDIR ] && echo "⚠ No input directory!" && exit 0
    [ ! -d $INPUTDIR ] && echo "⚠ Bad input directory:  \"$INPUTDIR\"!" && exit 0
    mkdir -p $RUNDIR/inputs
    cp -rf $INPUTDIR/* $RUNDIR/inputs/
    INPUTS=$(ls inputs/*)
    PRINTENV
    SAVEENV
    $RUNDIR/vplmodel/vpl_execution
    # => explicit run of vpl_execution
}


function START() {
    echo "START COMPILATION STAGE"
    CHECKENV
    if [ "$ONLINE" = "1" ] ; then
        START_ONLINE
    else
        START_OFFLINE $1
    fi
}

# EOF