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
    [ -z "$VERSION" ] && echo "⚠ MODE variable is not defined!" && exit 0
    [ -z "$MODE" ] && echo "⚠ MODE variable is not defined!" && exit 0
    [ -z "$REPOSITORY" ] && echo "⚠ REPOSITORY variable is not defined!" && exit 0
    [ -z "$BRANCH" ] && BRANCH="master"
    [ -z "$EXO" ] && echo "⚠ EXO variable is not defined!" && exit 0
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    [ -z "$DEBUG" ] && DEBUG=0
    [ -z "$VERBOSE" ] && VERBOSE=0
}

function SAVEENV()
{
    # export environment
    rm -f $RUNDIR/env.sh
    echo "VERSION=$VERSION" >> $RUNDIR/env.sh
    echo "MODE=$MODE" >> $RUNDIR/env.sh
    echo "REPOSITORY=$REPOSITORY" >> $RUNDIR/env.sh
    echo "BRANCH=$BRANCH" >> $RUNDIR/env.sh
    echo "EXO=$EXO" >> $RUNDIR/env.sh
    echo "RUNDIR=$RUNDIR" >> $RUNDIR/env.sh
    echo "DEBUG=$DEBUG" >> $RUNDIR/env.sh
    echo "VERBOSE=$VERBOSE" >> $RUNDIR/env.sh
}

function LOADENV()
{
    [ ! -f $RUNDIR/env.sh ] && echo "⚠ File \"env.sh\" missing!" && exit 0
    source $RUNDIR/env.sh
}

function EXPORTENV()
{
    export VERSION
    export MODE
    # export REPOSITORY
    # export BRANCH
    export EXO
    export RUNDIR
    export DEBUG
    export VERBOSE
}


function PRINTENV()
{
    ECHOV "VERSION=$VERSION"
    ECHOV "MODE=$MODE"
    # ECHOV "REPOSITORY=$REPOSITORY" # Don't show it, because of possible login & password!!!
    # ECHOV "BRANCH=$BRANCH"
    ECHOV "EXO=$EXO"
    ECHOV "RUNDIR=$RUNDIR"
    ECHOV "DEBUG=$DEBUG"
    ECHOV "VERBOSE=$VERBOSE"
}

### DOWNLOAD ###

# TODO: add wget method

function CLONE() {
    local REPOSITORY=$1
    local BRANCH=$2
    [ -z "$REPOSITORY" ] && echo "⚠ REPOSITORY variable is not defined!" && exit 0
    # git -c http.sslVerify=false clone -q -n $REPOSITORY --branch $BRANCH --depth 1 GIT
    git -c http.sslVerify=false clone -q -n $REPOSITORY --branch $BRANCH --depth 1 $RUNDIR/GIT
    [ ! $? -eq 0 ] && echo "⚠ GIT clone \"vplmoodle\" failure!" && exit 0
}

function CHECKOUT() {
    local DIR=$1
    cd $RUNDIR/GIT && git -c http.sslVerify=false checkout HEAD -- $DIR && cd
    [ ! $? -eq 0 ] && echo "⚠ GIT checkout \"$CHECKOUT\" failure!" && exit 0
}

function DOWNLOAD() {
    local DIR=$1
    START=$(date +%s.%N)
    CLONE $REPOSITORY $BRANCH
    CHECKOUT $DIR
    END=$(date +%s.%N)
    TIME=$(python -c "print(int(($END-$START)*1E3))") # in ms
    ECHOV "Download $EXO in $TIME ms"
}

### EXECUTION ###

function START() {
    CHECKENV
    PRINTENV
    DOWNLOAD $EXO
    SAVEENV
    cp $RUNDIR/vplmodel/vpl_execution $RUNDIR
    chmod +x $RUNDIR/vpl_execution
    # => implicit execution of vpl_execution
}

# EOF