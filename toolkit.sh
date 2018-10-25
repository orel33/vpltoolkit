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
    ENVDIR=$HOME
    if [ "$ONLINE" = "0" ] ; then ENVDIR=$RUNDIR ; fi
    rm -f $ENVDIR/env.sh
    echo "VERSION=$VERSION" >> $ENVDIR/env.sh
    echo "MODE=$MODE" >> $ENVDIR/env.sh
    echo "ONLINE=$ONLINE" >> $ENVDIR/env.sh
    echo "EXO=$EXO" >> $ENVDIR/env.sh
    echo "RUNDIR=$RUNDIR" >> $ENVDIR/env.sh
    echo "DEBUG=$DEBUG" >> $ENVDIR/env.sh
    echo "VERBOSE=$VERBOSE" >> $ENVDIR/env.sh
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
    [ -z "$REPOSITORY" ] && echo "⚠ REPOSITORY variable is not defined!" && exit 0
    [ -z "$BRANCH" ] && echo "⚠ BRANCH variable is not defined!" && exit 0
    [ -z "$SUBDIR" ] && echo "⚠ SUBDIR variable is not defined!" && exit 0
    git -c http.sslVerify=false clone -q -n $REPOSITORY --branch $BRANCH --depth 1 $RUNDIR/download
    [ ! $? -eq 0 ] && echo "⚠ GIT clone repository failure!" && exit 0
    cd $RUNDIR/download && git -c http.sslVerify=false checkout HEAD -- $SUBDIR && cd -
    [ ! $? -eq 0 ] && echo "⚠ GIT checkout subdir failure!" && exit 0
    END=$(date +%s.%N)
    TIME=$(python -c "print(int(($END-$START)*1E3))") # in ms
    ECHOV "GIT download in $TIME ms"
    rm -rf $RUNDIR/download/$SUBDIR/.git
}

### EXECUTION ###

function START() {
    CHECKENV
    PRINTENV
    SAVEENV
    EXPORTENV

    if [ "$ONLINE" = "1" ] ; then
        # => implicit run of $vpl_execution
        cp $RUNDIR/vplmodel/vpl_execution $HOME && chmod +x $HOME/vpl_execution
        # ln -sf $RUNDIR/vplmodel/vpl_execution $HOME/vpl_execution
    else
        # => explicit run of vpl_execution
        source $RUNDIR/vplmodel/vpl_execution
    fi
}

# EOF