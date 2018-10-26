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

### GRADE ###

SCORE()
{
    [ $# -ne 1 ] && echo "⚠ Usage: SCORE VALUE" && exit 0
    [ -z "$GRADE" ] && GRADE=0
    local VALUE=$1
    [ -z "$GRADE" ] && echo "⚠ GRADE variable is not defined!" && exit 0
    ECHOD "GRADE += $VALUE"
    GRADE=$((GRADE+VALUE))
}

EXIT()
{
    [ -z "$GRADE" ] && GRADE=0
    (( GRADE < 0 )) && GRADE=0
    (( GRADE > 100 )) && GRADE=100
    ECHO && ECHO "-GRADE" && ECHO "$GRADE / 100"
    if [ "$MODE" = "EVALUATE" ] ; then echo "Grade :=>> $GRADE" ; fi
    # if [ "$MODE" = "RUN" ] ; then echo "Use Ctrl+Shift+⇧ / Ctrl+Shift+⇩ to scroll up / down..." ; fi
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
    ECHOV
    ECHOV "-ENVIRONMENT"
    ECHOV "VERSION=$VERSION"
    ECHOV "ONLINE=$ONLINE"
    ECHOV "MODE=$MODE"
    ECHOV "EXO=$EXO"
    ECHOV "RUNDIR=$RUNDIR"
    ECHOV "DEBUG=$DEBUG"
    ECHOV "VERBOSE=$VERBOSE"
    ECHOV "INPUTS=$INPUTS"
    ECHOV
}

### DOWNLOAD ###

# TODO: add wget method

function DOWNLOAD() {
    [ $# -ne 3 ] && echo "⚠ Usage: DOWNLOAD REPOSITORY BRANCH SUBDIR" && exit 0
    local REPOSITORY=$1
    local BRANCH=$2
    local SUBDIR=$3
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    START=$(date +%s.%N)
    mkdir -p $RUNDIR/download
    [ -z "$REPOSITORY" ] && echo "⚠ REPOSITORY variable is not defined!" && exit 0
    [ -z "$BRANCH" ] && echo "⚠ BRANCH variable is not defined!" && exit 0
    [ -z "$SUBDIR" ] && echo "⚠ SUBDIR variable is not defined!" && exit 0
    git -c http.sslVerify=false clone -q -n $REPOSITORY --branch $BRANCH --depth 1 $RUNDIR/download &> /dev/null
    [ ! $? -eq 0 ] && echo "⚠ GIT clone repository failure (branch \"$BRANCH\")!" && exit 0
    ( cd $RUNDIR/download && git -c http.sslVerify=false checkout HEAD -- $SUBDIR &> /dev/null )
    [ ! $? -eq 0 ] && echo "⚠ GIT checkout \"$SUBDIR\" failure!" && exit 0
    [ ! -d $RUNDIR/download/$SUBDIR ] && ECHO "⚠ SUBDIR \"$SUBDIR\" is missing!" && exit 0
    END=$(date +%s.%N)
    TIME=$(python -c "print(int(($END-$START)*1E3))") # in ms
    ECHOV "Download \"$SUBDIR\" in $TIME ms"
    cp -rf $RUNDIR/download/$SUBDIR/* $RUNDIR/
    # rm -rf $RUNDIR/download
    # ls -lR $RUNDIR
}

### EXECUTION ###

function START_ONLINE() {
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    [ ! -d $RUNDIR ] && echo "⚠ Bad RUNDIR: \"$RUNDIR\"!" && exit 0
    ONLINE=1
    [ $(basename $0) == "vpl_run.sh" ] && MODE="RUN"
    [ $(basename $0) == "vpl_evaluate.sh" ] && MODE="EVAL"
    [ -z "$MODE" ] && echo "⚠ MODE variable is not defined!" && exit 0
    source $HOME/vpl_environment.sh
    mkdir -p $RUNDIR/inputs
    [ ! -z "$VPL_SUBFILES" ] && ( cd $HOME && cp $VPL_SUBFILES $RUNDIR/inputs )
    INPUTS=\"$(cd $RUNDIR && find inputs -maxdepth 1 -type f | xargs)\"
    # INPUTS=$(echo -n \" && cd $RUNDIR && find inputs -maxdepth 1 -type f | xargs && echo -n \")
    CHECKENV
    PRINTENV
    SAVEENV
    cp $RUNDIR/env.sh $HOME
    cp $RUNDIR/vpltoolkit/toolkit.sh $HOME
    cp $RUNDIR/vpltoolkit/vpl_execution $HOME
    # => implicit run of vpl_execution in $HOME
}


function START_OFFLINE() {
    [ $# -ne 0 -a $# -ne 1 ] && echo "⚠ Usage: START_OFFLINE [INPUTDIR]" && exit 0
    local INPUTDIR=$1
    [ ! -z "$INPUTDIR" ] && [ ! -d $INPUTDIR ] && echo "⚠ Bad INPUTDIR: \"$INPUTDIR\"!" && exit 0
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    [ ! -d $RUNDIR ] && echo "⚠ Bad RUNDIR: \"$RUNDIR\"!" && exit 0
    ONLINE=0
    [ $(basename $0) == "local_run.sh" ] && MODE="RUN"
    [ $(basename $0) == "local_evaluate.sh" ] && MODE="EVAL"
    [ -z "$MODE" ] && echo "⚠ MODE variable is not defined!" && exit 0
    mkdir -p $RUNDIR/inputs
    [ ! -z "$INPUTDIR" ] && find $INPUTDIR -maxdepth 1 -type f -exec cp -t $RUNDIR/inputs/ {} +
    [ ! -z "$INPUTDIR" ] && INPUTS=\"$(cd $RUNDIR && find inputs -maxdepth 1 -type f | xargs)\"
    CHECKENV
    PRINTENV
    SAVEENV
    cd $RUNDIR
    $RUNDIR/vpltoolkit/vpl_execution
    # => explicit run of vpl_execution in $RUNDIR
}

# EOF