#!/bin/bash

VERSION="1.0"

### BASIC ROUTINES ###

# this routines should be used only in run.sh & eval.sh

# COMMENT only for EVAL mode
# no color in EVAL mode 

COMMENT()
{
    echo "Comment :=>>$@"
}

TITLE()
{
    echo "Comment :=>>-$@"
}

ECHOGREEN()
{
    echo -n -e "\033[32m"
    echo "$@"
    echo -n -e "\033[0m"
}

ECHORED()
{
    echo -n -e "\033[31m"
    ECHO "$@"
    echo -n -e "\033[0m"
}

ECHO()
{
    local COMMENT=""
    if [ "$MODE" = "EVAL" ] ; then COMMENT="Comment :=>>" ; fi
    echo "${COMMENT}$@"
}

# echo a command and then execute it (both for RUN & EVAL modes)

TRACE()
{
    if [ "$MODE" = "EVAL" ] ; then
        COMMENT "$ $@"
        COMMENT "< | -"
        # bash -c "$@" |& sed -e 's/^/Comment :=>>/;'
        bash -c "$@" |& sed -e 's/^/>/;'   # preformated output
        COMMENT "- | >"
    else
        ECHOGREEN "$ $@"
        bash -c "$@"
    fi
}

# ECHO and TRACE in VERBOSE mode

ECHOV()
{
    if [ "$VERBOSE" = "1" ] ; then ECHO "$@" ; fi
}

TRACEV()
{
    if [ "$VERBOSE" = "1" ] ; then
        TRACE "$@"
    else
        bash -c "$@" &> /dev/null
    fi
}

### MISC ###

CHECK()
{
    for FILE in "$@" ; do
        [ ! -f $FILE ] && ECHO "⚠ File \"$FILE\" is missing!" && exit 0
    done
}

CHECKINPUTS()
{
    [ -z "$INPUTS" ] && echo "⚠ INPUTS variable is not defined!" && exit 0
    CHECK $INPUTS
}

COPYINPUTS()
{
    [ -z "$INPUTS" ] && echo "⚠ INPUTS variable is not defined!" && exit 0
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    cp -f $INPUTS $RUNDIR/
}

### GRADE ###

SCORE()
{
    [ $# -ne 1 ] && ECHO "⚠ Usage: SCORE VALUE" && exit 0
    [ -z "$GRADE" ] && GRADE=0
    local VALUE=$1
    [ -z "$GRADE" ] && echo "⚠ GRADE variable is not defined!" && exit 0
    ECHOV "GRADE += $VALUE"
    GRADE=$((GRADE+VALUE))
}

EXIT()
{
    [ -z "$GRADE" ] && GRADE=0
    (( GRADE < 0 )) && GRADE=0
    (( GRADE > 100 )) && GRADE=100
    ECHO && ECHO "-GRADE" && ECHO "$GRADE / 100"
    if [ "$MODE" = "EVAL" ] ; then echo "Grade :=>> $GRADE" ; fi
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
    if [ "$VERBOSE" = "1" ] ; then
        echo
        echo "VERSION=$VERSION"
        echo "ONLINE=$ONLINE"
        echo "MODE=$MODE"
        echo "EXO=$EXO"
        echo "RUNDIR=$RUNDIR"
        echo "DEBUG=$DEBUG"
        echo "VERBOSE=$VERBOSE"
        echo "INPUTS=$INPUTS"
        echo
    fi
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
    [ "$VERBOSE" = "1" ] && echo "Download \"$SUBDIR\" in $TIME ms"
    cp -rf $RUNDIR/download/$SUBDIR/* $RUNDIR/
    # rm -rf $RUNDIR/download
    # ls -lR $RUNDIR
}

### EXECUTION ###

function START_ONLINE() {
    [ "$VERBOSE" = "1" ] && echo "Start VPL Compilation Stage"
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
    [ "$VERBOSE" = "1" ] && echo "Start VPL Compilation Stage"
    [ $# -ne 0 -a $# -ne 1 ] && echo "⚠ Usage: START_OFFLINE [INPUTDIR]" && exit 0
    local INPUTDIR=$1
    [ ! -z "$INPUTDIR" ] && [ ! -d $INPUTDIR ] && echo "⚠ Bad INPUTDIR: \"$INPUTDIR\"!" && exit 0
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    [ ! -d $RUNDIR ] && echo "⚠ Bad RUNDIR: \"$RUNDIR\"!" && exit 0
    ONLINE=0
    [ $(basename $0) == "local_run.sh" ] && MODE="RUN"
    [ $(basename $0) == "local_eval.sh" ] && MODE="EVAL"
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
