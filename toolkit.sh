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
}

function LOADENV()
{
    ENVDIR=$HOME
    if [ "$ONLINE" = "0" ] ; then ENVDIR=$RUNDIR ; fi
    [ ! -f $ENVDIR/env.sh ] && echo "⚠ File \"env.sh\" missing!" && exit 0
    source $ENVDIR/env.sh
}

function EXPORTENV()
{
    export VERSION
    export ONLINE
    export MODE
    export EXO
    export RUNDIR
    export DEBUG
    export VERBOSE
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
    ECHOV "GIT download $SUBDIR in $TIME ms"
    cp -rf $RUNDIR/download/$SUBDIR/* $RUNDIR/
    # rm -rf $RUNDIR/download
    # ls -lR $RUNDIR
}

### COPY INPUTS ###

function COPYINPUTS() {
    echo "=> copy inputs: $@"
    mkdir -p $RUNDIR/inputs
    for FILE in "$@" ; do
        [ ! -f $FILE ] && ECHO "⚠ Input file \"$FILE\" is missing!" && exit 0
        cp $FILE $RUNDIR/inputs/
    done
}

### EXECUTION ###

function START() {
    echo "START COMPILATION STAGE"
    CHECKENV
    PRINTENV
    SAVEENV

    if [ "$ONLINE" = "1" ] ; then
        source $HOME/vpl_environment.sh
        COPYINPUTS $VPL_SUBFILES
        cp $RUNDIR/env.sh $HOME
        cp $RUNDIR/vplmodel/toolkit.sh $HOME
        cp $RUNDIR/vplmodel/vpl_execution $HOME && chmod +x $HOME
        # => implicit run of $vpl_execution
    else
        # cp -rf $INPUTDIR/* $RUNDIR/inputs/
        source $RUNDIR/vplmodel/vpl_execution
        # => explicit run of vpl_execution
    fi
}

# EOF