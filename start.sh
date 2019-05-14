#!/bin/bash

# rm -f $0

VERSION="4.0"
LOG="$RUNDIR/start.log"

### ENVIRONMENT ###

function CHECKENV()
{
    # basic environment
    [ -z "$VERSION" ] && echo "⚠ VERSION variable is not defined!" && exit 0
    [ -z "$ONLINE" ] && echo "⚠ ONLINE variable is not defined!" && exit 0
    [ -z "$MODE" ] && echo "⚠ MODE variable is not defined!" && exit 0
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    [ -z "$GRAPHIC" ] && GRAPHIC=0
    [ -z "$DOCKER" ] && DOCKER=""
    [ -z "$DOCKERTIMEOUT" ] && DOCKERTIMEOUT="900"
    [ -z "$DEBUG" ] && DEBUG=0
    [ -z "$VERBOSE" ] && VERBOSE=0
    [ -z "$ENTRYPOINT" ] && ENTRYPOINT="run.sh"
    [ -z "$ARGS" ] && ARGS=""
    [ -z "$INPUTS" ] && INPUTS=""
}

function SAVEENV()
{
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    rm -f $RUNDIR/env.sh
    echo "VERSION=$VERSION" >> $RUNDIR/env.sh
    echo "MODE=$MODE" >> $RUNDIR/env.sh
    echo "ONLINE=$ONLINE" >> $RUNDIR/env.sh
    echo "RUNDIR=$RUNDIR" >> $RUNDIR/env.sh
    echo "GRAPHIC=$GRAPHIC" >> $RUNDIR/env.sh
    echo "DOCKER=$DOCKER" >> $RUNDIR/env.sh
    echo "DOCKERTIMEOUT=$DOCKERTIMEOUT" >> $RUNDIR/env.sh
    echo "DEBUG=$DEBUG" >> $RUNDIR/env.sh
    echo "VERBOSE=$VERBOSE" >> $RUNDIR/env.sh
    echo "ENTRYPOINT=$ENTRYPOINT" >> $RUNDIR/env.sh
    echo "ARGS=$ARGS" >> $RUNDIR/env.sh
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
    echo "* VERSION=$VERSION"
    echo "* ONLINE=$ONLINE"
    echo "* MODE=$MODE"
    echo "* RUNDIR=$RUNDIR"
    echo "* DOCKER=$DOCKER"
    echo "* DOCKERTIMEOUT=$DOCKERTIMEOUT"
    echo "* GRAPHIC=$GRAPHIC"
    echo "* DEBUG=$DEBUG"
    echo "* VERBOSE=$VERBOSE"
    echo "* ENTRYPOINT=$ENTRYPOINT"
    echo "* ARGS=$ARGS"
    echo "* INPUTS=$INPUTS"
}

### DOWNLOAD ###

# TODO: add WGET and SCP methods

### DOWNLOAD TEACHER FILES FROM GIT REPOSITORY (and COPY FILES in RUNDIR)
function DOWNLOAD()
{
    if [ $# -eq 1 ] ; then
        local REPOSITORY="$1"
        local BRANCH="master"
        local SUBDIR=""
    elif [ $# -eq 2 ] ; then
        local REPOSITORY="$1"
        local BRANCH="$2"
        local SUBDIR=""
    elif [ $# -eq 3 ] ; then
        local REPOSITORY="$1"
        local BRANCH="$2"
        local SUBDIR="$3"
    else
        echo "⚠ Usage: DOWNLOAD REPOSITORY [BRANCH [SUBDIR]]" && exit 0
    fi

    START=$(date +%s.%N)
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    mkdir -p $RUNDIR/download
    [ -z "$REPOSITORY" ] && echo "⚠ REPOSITORY variable is not defined!" && exit 0
    [ -z "$BRANCH" ] && echo "⚠ BRANCH variable is not defined!" && exit 0
    # [ -z "$SUBDIR" ] && echo "⚠ SUBDIR variable is not defined!" && exit 0
    # git clone (without checkout of HEAD)
    ( timeout 10 git -c http.sslVerify=false clone -q -n $REPOSITORY --branch $BRANCH --depth 1 $RUNDIR/download ) &>> $LOG
    RET=$?
    [ $RET -eq 124 ] && echo "⚠ GIT clone repository failure (timeout)!" && exit 0
    [ $RET -ne 0 ] && echo "⚠ GIT clone repository failure (branch \"$BRANCH\")!" && exit 0

    # checkout only what is needed
    if [ -n "$SUBDIR" ] ; then
        ( cd $RUNDIR/download && timeout 10 git -c http.sslVerify=false checkout HEAD -- $SUBDIR ) &>> $LOG
        RET=$?
        [ $RET -eq 124 ] && echo "⚠ GIT checkout failure (timeout)!" && exit 0
        [ $RET -ne 0 ] && echo "⚠ GIT checkout failure (subdir \"$SUBDIR\")!" && exit 0
        [ ! -d $RUNDIR/download/$SUBDIR ] && ECHO "⚠ SUBDIR \"$SUBDIR\" is missing!" && exit 0
        mv -f $RUNDIR/download/$SUBDIR/* $RUNDIR/ &>> $LOG  # hidden files are not copied!
    else
        ( cd $RUNDIR/download && timeout 10 git -c http.sslVerify=false checkout HEAD ) &>> $LOG
        RET=$?
        [ $RET -eq 124 ] && echo "⚠ GIT checkout failure (timeout)!" && exit 0
        [ $RET -ne 0 ] && echo "⚠ GIT checkout failure!" && exit 0
        mv -f $RUNDIR/download/* $RUNDIR/ &>> $LOG  # hidden files are not copied!
    fi
    # rm -rf $RUNDIR/.git/ &>> $LOG # for security issue, but useless here
    rm -rf $RUNDIR/download &>> $LOG
    END=$(date +%s.%N)          # FIXME: problem with %N (nanoseconds) option on MacOS
    TIME=$(python -c "print(int(($END-$START)*1E3))") # in ms
    [ "$VERBOSE" = "1" ] && echo "Download teacher repository in $TIME ms"

}

### EXECUTION ###

function START_ONLINE()
{
    [ ! $# -ge 0 ] && echo "⚠ Usage: START_ONLINE [...]" && exit 0
    ARGS=\"${@:1}\"
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    [ ! -d $RUNDIR ] && echo "⚠ Bad RUNDIR: \"$RUNDIR\"!" && exit 0
    ONLINE=1
    [ $(basename $0) == "vpl_run.sh" ] && MODE="RUN"
    [ $(basename $0) == "vpl_debug.sh" ] && MODE="DEBUG"
    [ $(basename $0) == "vpl_evaluate.sh" ] && MODE="EVAL"
    [ -z "$MODE" ] && echo "⚠ MODE variable is not defined!" && exit 0
    grep -w $MODE <<< "RUN DEBUG EVAL" &> /dev/null
    [ $? -ne 0 ] && echo "⚠ Invalid MODE \"$MODE\"!" && exit 0
    source $HOME/vpl_environment.sh
    mkdir -p $RUNDIR/inputs
    # [ ! -z "$VPL_SUBFILES" ] && ( cd $HOME && cp $VPL_SUBFILES $RUNDIR/inputs ) # FIXME: here bug if file contains spaces
    for var in ${!VPL_SUBFILE@} ; do
        # $var => variable name  and ${!var} => variable value
        [ "$var" = "VPL_SUBFILES" ] && continue
        local file="${!var}"
        # decode binary file
        if [ -f "$file.b64" ] ; then 
            # echo "⚠ decode file \"$file.b64\""
            base64 -d "$file.b64" > "$file"
            [ ! $? -eq 0 ] && echo "⚠ cannot decode file \"$file.b64\"!"
        fi
        [ ! -f "$file" ] && echo "⚠ input file \"$file\" not found!" && continue
        cp -f "$file" $RUNDIR/inputs &> /dev/null
        [ ! $? -eq 0 ] && echo "⚠ cannot copy input file \"$file\" in inputs directory!"
    done
    INPUTS="$RUNDIR/inputs/"
    CHECKENV
    SAVEENV
    rm -rf $RUNDIR/vpltoolkit/.git/ &> /dev/null # for security issue
    cp $RUNDIR/env.sh $HOME
    cp $RUNDIR/vpltoolkit/toolkit.sh $HOME
    cp $RUNDIR/vpltoolkit/vpl_execution $HOME
    # graphic session
    [ $GRAPHIC -eq 1 ] && mv $HOME/vpl_execution $HOME/vpl_wexecution
    # print in compilation window
    echo "Start VPL Toolkit in $SECONDS sec..."
    PRINTENV
    # => implicit run of vpl_execution in $HOME
}

function START_OFFLINE()
{
    [ ! $# -ge 1 ] && echo "⚠ Usage: START_OFFLINE INPUTDIR [...]" && exit 0
    local INPUTDIR="$1"
    local ARGS=\"${@:2}\"
    [ ! -z "$INPUTDIR" ] && [ ! -d $INPUTDIR ] && echo "⚠ Bad INPUTDIR: \"$INPUTDIR\"!" && exit 0
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    [ ! -d $RUNDIR ] && echo "⚠ Bad RUNDIR: \"$RUNDIR\"!" && exit 0
    ONLINE=0
    [ $(basename $0) == "local_run.sh" ] && MODE="RUN"
    [ $(basename $0) == "local_debug.sh" ] && MODE="DEBUG"
    [ $(basename $0) == "local_eval.sh" ] && MODE="EVAL"
    [ -z "$MODE" ] && echo "⚠ MODE variable is not defined!" && exit 0
    grep -w $MODE <<< "RUN DEBUG EVAL" &> /dev/null
    [ $? -ne 0 ] && echo "⚠ Invalid MODE \"$MODE\"!" && exit 0
    mkdir -p $RUNDIR/inputs
    cp $INPUTDIR/* $RUNDIR/inputs/ &> /dev/null     # FIXME: error if no inputs
    INPUTS="$RUNDIR/inputs/"
    CHECKENV
    SAVEENV
    rm -rf $RUNDIR/vpltoolkit/.git/ &> /dev/null # for security issue
    echo "Start VPL Toolkit in $SECONDS sec..."
    PRINTENV
    cd $RUNDIR && $RUNDIR/vpltoolkit/vpl_execution
    # => explicit run of vpl_execution in $RUNDIR
}

# EOF
