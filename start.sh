#!/bin/bash

VERSION="4.0"

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
    echo "* ARGS=$ARGS"
    echo "* INPUTS=$INPUTS"
}

### DOWNLOAD ###

# TODO: add WGET and SCP methods

### DOWNLOAD EXTRA REPOSITORY
function DOWNLOADEXT()
{
    [ $# -ne 4 ] && echo "⚠ Usage: DOWNLOADEXT REPOSITORY BRANCH SUBDIR TARGETDIR" && exit 0
    local REPOSITORY="$1"
    local BRANCH="$2"
    local SUBDIR="$3"       # TODO: SUBDIR could be optional, download all...
    local TARGETDIR="$4"

    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    mkdir -p $RUNDIR/download

    START=$(date +%s.%N)
    mkdir -p $RUNDIR/download/$TARGETDIR
    [ -z "$REPOSITORY" ] && echo "⚠ REPOSITORY variable is not defined!" && exit 0
    [ -z "$BRANCH" ] && echo "⚠ BRANCH variable is not defined!" && exit 0
    [ -z "$SUBDIR" ] && echo "⚠ SUBDIR variable is not defined!" && exit 0
    git -c http.sslVerify=false clone -q -n $REPOSITORY --branch $BRANCH --depth 1 $RUNDIR/download/$TARGETDIR &> /dev/null
    [ ! $? -eq 0 ] && echo "⚠ GIT clone repository failure (branch \"$BRANCH\")!" && exit 0
    ( cd $RUNDIR/download/$TARGETDIR && git -c http.sslVerify=false checkout HEAD -- $SUBDIR &> /dev/null )
    [ ! $? -eq 0 ] && echo "⚠ GIT checkout \"$SUBDIR\" failure!" && exit 0
    [ ! -d $RUNDIR/download/$TARGETDIR/$SUBDIR ] && ECHO "⚠ SUBDIR \"$SUBDIR\" is missing!" && exit 0
    rm -rf $RUNDIR/download/$TARGETDIR/.git/ &> /dev/null # for security issue
    END=$(date +%s.%N)
    TIME=$(python -c "print(int(($END-$START)*1E3))") # in ms
    [ "$VERBOSE" = "1" ] && echo "Download \"$SUBDIR\" in $TIME ms"
}

### DOWNLOAD MAIN REPOSITORY (and COPY FILES in RUNDIR)
function DOWNLOAD()
{
    [ $# -ne 3 ] && echo "⚠ Usage: DOWNLOAD REPOSITORY BRANCH SUBDIR" && exit 0
    local REPOSITORY="$1"
    local BRANCH="$2"
    local SUBDIR="$3"
    local TARGETDIR="main"
    DOWNLOADEXT "$REPOSITORY" "$BRANCH" "$SUBDIR" "$TARGETDIR"
    # copy run.sh and/or eval.sh scripts
    cp -rf $RUNDIR/download/$TARGETDIR/$SUBDIR/* $RUNDIR/
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
    source $HOME/vpl_environment.sh
    mkdir -p $RUNDIR/inputs
    # [ ! -z "$VPL_SUBFILES" ] && ( cd $HOME && cp $VPL_SUBFILES $RUNDIR/inputs ) # FIXME: here bug if file contains spaces
    for var in ${!VPL_SUBFILE@} ; do
        # $var => variable name  and ${!var} => variable value
        [ "$var" = "VPL_SUBFILES" ] && continue
        local file="${!var}"
        # decode binary file
        if [ -f "$file.b64" ] ; then 
            base64 -d "$file.b64" > $file # 2> /dev/null
            [ ! $? -eq 0 ] && echo "⚠ cannot decode file \"$file.b64\"!"
        fi
        [ ! -f "$file" ] && echo "⚠ input file \"$file\" not found!" && continue
        cp -f "$file" $RUNDIR/inputs &> /dev/null
        [ ! $? -eq 0 ] && echo "⚠ cannot copy input file \"$file\" in inputs directory!"
        # TODO: check no empty file
        # grep -q ' ' <<< "$file" && echo "⚠ input file \"$file\" with spaces not allowed!" # && exit 0
    done
    INPUTS="$RUNDIR/inputs/"
    # INPUTS=\"$(cd $RUNDIR && find -L inputs -maxdepth 1 -type f | xargs)\" # FIXME: here bug if file contains spaces
    # INPUTS="$(cd $RUNDIR && find -L inputs -maxdepth 1 -type f -exec echo \"{}\" \;)"
    # echo INPUTS="$INPUTS"

    # INPUTS=$(echo -n \" && cd $RUNDIR && find inputs -maxdepth 1 -type f | xargs && echo -n \")
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
    # [ ! $# -ge 1 ] && echo "⚠ Usage: START_OFFLINE INPUTDIR [...]" && exit 0
    local INPUTDIR="$1"
    local ARGS=\"${@:2}\"
    # [ -z "$INPUTDIR" ] && echo "⚠ INPUTDIR variable is not defined!" && exit 0
    [ ! -z "$INPUTDIR" ] && [ ! -d $INPUTDIR ] && echo "⚠ Bad INPUTDIR: \"$INPUTDIR\"!" && exit 0
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    [ ! -d $RUNDIR ] && echo "⚠ Bad RUNDIR: \"$RUNDIR\"!" && exit 0
    ONLINE=0
    [ $(basename $0) == "local_run.sh" ] && MODE="RUN"
    [ $(basename $0) == "vpl_debug.sh" ] && MODE="DEBUG"
    [ $(basename $0) == "local_eval.sh" ] && MODE="EVAL"
    [ -z "$MODE" ] && echo "⚠ MODE variable is not defined!" && exit 0
    mkdir -p $RUNDIR/inputs
    cp $INPUTDIR/* $RUNDIR/inputs/
    INPUTS="$RUNDIR/inputs/"
    # [ ! -z "$INPUTDIR" ] && find -L $INPUTDIR -maxdepth 1 -type f -exec cp -t $RUNDIR/inputs/ "{}" +  # TODO: bug? with +... use \;
    # [ ! -z "$INPUTDIR" ] && INPUTS=\"$(cd $RUNDIR && find -L inputs -maxdepth 1 -type f | xargs)\"
    CHECKENV
    SAVEENV
    rm -rf $RUNDIR/vpltoolkit/.git/ &> /dev/null # for security issue
    echo "Start VPL Toolkit in $SECONDS sec..."
    PRINTENV
    cd $RUNDIR && $RUNDIR/vpltoolkit/vpl_execution
    # => explicit run of vpl_execution in $RUNDIR
}

# EOF
