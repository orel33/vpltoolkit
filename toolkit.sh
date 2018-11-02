#!/bin/bash

VERSION="1.0"

### BASIC ECHO ROUTINES ###

# Nota Bene:
# * in RUN mode, all outputs are visible in a terminal window by students (as a basic shell script)
# * in EVAL mode, all outputs in comment window are visible by students (it is the main output window)
# * in EVAL mode, all outputs in execution window are only visible by teacher (for debug purpose)

# echo in comment window (EVAL mode only)
function COMMENT
{
    echo "Comment :=>>$@"
}

# title in comment window (EVAL mode only)
function TITLE
{
    echo "Comment :=>>-$@"
}

# pre-formatted echo in comment window (EVAL mode only)
function PRE
{
    echo "Comment :=>>>$@"
}

# echo in blue (RUN mode only)
function ECHOBLUE
{
    echo -n -e "\033[34m" && echo -n "$@" && echo -e "\033[0m"
}

# echo in green (RUN mode only)
function ECHOGREEN
{
    echo -n -e "\033[32m" && echo -n "$@" && echo -e "\033[0m"
}

# echo in red (RUN mode only)
function ECHORED
{
    echo -n -e "\033[31m"  && echo -n "$@" && echo -e "\033[0m"
}

# echo both in RUN & EVAL modes
function ECHO
{
    if [ "$MODE" = "RUN" ] ; then
        echo "$@"
    else
        echo "Comment :=>>$@"
    fi
}

# echo in verbose mode only
function ECHOV
{
    if [ "$VERBOSE" = "1" ] ; then ECHO "$@" ; fi
}

### BASIC TRACE ROUTINES ###

# echo a command (in green) and execute it (RUN mode only)
function RTRACE
{
    [ "$MODE" != "RUN" ] && "Error: function RTRACE only available in RUN mode!" && exit 0
    ECHOGREEN "$ $@"
    bash -c "$@"
    RET=$?
    return $RET
}

# echo a command in execution window and execute it (EVAL mode only)
function TRACE
{
    [ "$MODE" != "EVAL" ] && "Error: function TRACE only available in EVAL mode!" && exit 0
    echo "Trace :=>>$ $@"
    bash -c "$@" |& sed -e 's/^/Output :=>>/;'
    RET=${PIPESTATUS[0]}  # return status of first piped command!
    echo "Status :=>> $RET"
    return $RET
}

# echo a command in comment window and execute it (EVAL mode only)
function VTRACE
{
    [ "$MODE" != "EVAL" ] && "Error: function VTRACE only available in EVAL mode!" && exit 0
    COMMENT "$ $@"
    echo "<|--"
    bash -c "$@" |& sed -e 's/^/>/;' # preformated output
    RET=${PIPESTATUS[0]}  # return status of first piped command!
    echo "--|>"
    return $RET
}

### MISC ###

function CHECK
{
    for FILE in "$@" ; do
        [ ! -f $FILE ] && ECHO "⚠ File \"$FILE\" is missing!" && exit 0
    done
}

function CHECKINPUTS
{
    [ -z "$INPUTS" ] && echo "⚠ INPUTS variable is not defined!" && exit 0
    CHECK $INPUTS
}

function COPYINPUTS
{
    [ -z "$INPUTS" ] && echo "⚠ INPUTS variable is not defined!" && exit 0
    [ -z "$RUNDIR" ] && echo "⚠ RUNDIR variable is not defined!" && exit 0
    cp -f $INPUTS $RUNDIR/
}

### GRADE ###

# inputs: [GRADE]
function EXIT
{
    [ -z "$GRADE" ] && GRADE=0
    [ $# -eq 1 ] && GRADE=$1
    (( GRADE < 0 )) && GRADE=0
    (( GRADE > 100 )) && GRADE=100
    ECHO && ECHO "-GRADE" && ECHO "$GRADE / 100"
    if [ "$MODE" = "EVAL" ] ; then echo "Grade :=>> $GRADE" ; fi
    # if [ "$MODE" = "RUN" ] ; then echo "Use Ctrl+Shift+⇧ / Ctrl+Shift+⇩ to scroll up / down..." ; fi
    exit 0
}

# function SCORE
# {
#     [ $# -ne 1 ] && ECHO "⚠ Usage: SCORE VALUE" && exit 0
#     [ -z "$GRADE" ] && GRADE=0
#     local VALUE=$1
#     [ -z "$GRADE" ] && echo "⚠ GRADE variable is not defined!" && exit 0
#     # ECHOV "GRADE += $VALUE"
#     GRADE=$((GRADE+VALUE))
# }

# inputs: MSG VALUE [MSGOK] [CMDOK]
function SUCCESS
{
    local MSG="$1"
    local VALUE="$2"
    local MSGOK="success."
    local CMDOK=""
    if [ $# -eq 3 ] ; then
        MSGOK="$3"
    elif [ $# -eq 4 ] ; then
        MSGOK="$3"
        CMDOK="$4"
    fi
    if [ "$VALUE" = "X" ] ; then
        COMMENT "✓ $MSG: $MSGOK [+∞]" && EXIT 100
    elif [ "$VALUE" = "0" ] ; then
        COMMENT "✓ $MSG: $MSGOK"
    else
        COMMENT "✓ $MSG: $MSGOK [+$VALUE]"
    fi
    GRADE=$((GRADE+VALUE))
    eval $CMDOK
    return 0
}

# inputs: MSG VALUE [MSGOK] [CMDKO]
function FAILURE
{
    local MSG="$1"
    local VALUE="$2"
    local MSGKO="failure!"
    local CMDKO=""
    if [ $# -eq 3 ] ; then
        MSGKO="$3"
    elif [ $# -eq 4 ] ; then
        MSGKO="$3"
        CMDKO="$4"
    fi
    if [ "$VALUE" = "X" ] ; then
        COMMENT "⚠ $MSG: $MSGKO [-∞]" && EXIT 0
    elif [ "$VALUE" = "0" ] ; then
        COMMENT "⚠ $MSG: $MSGKO"
    else
        COMMENT "⚠ $MSG: $MSGKO [-$VALUE]"
    fi
    GRADE=$((GRADE-VALUE))
    eval $CMDKO
    return 1
}

# inputs: MSG VALUEBONUS VALUEMALUS [MSGOK MSGKO] [CMDOK CMDKO]
function EVAL
{
    local RET=$?
    [ "$MODE" != "EVAL" ] && "Error: function EVAL only available in EVAL mode!" && exit 0
    local MSG="$1"
    local VALUEBONUS="$2"
    local VALUEMALUS="$3"
    local MSGOK="success."
    local MSGKO="failure!"
    local CMDOK=""
    local CMDKO=""
    if [ $# -eq 5 ] ; then
        MSGOK=$4
        MSGKO=$5
    elif [ $# -eq 7 ] ; then
        MSGOK=$4
        MSGKO=$5
        CMDOK=$6
        CMDKO=$7
    fi
    if [ $RET -eq 0 ] ; then
        SUCCESS "$MSG" $VALUEBONUS "$MSGOK" "$CMDOK"
    else
        FAILURE "$MSG" $VALUEMALUS "$MSGKO" "$CMDKO"
    fi
    return $RET
}


# inputs: MSG [MSGOK] [CMDOK]
function RSUCCESS
{
    [ "$MODE" != "RUN" ] && "Error: function REVAL only available in RUN mode!" && exit 0
    local MSG="$1"
    local MSGOK="success."
    local CMDOK=""
    if [ $# -eq 2 ] ; then
        MSGOK="$2"
    elif [ $# -eq 3 ] ; then
        MSGOK="$2"
        CMDOK="$3"
    fi
    ECHOBLUE "✓ $MSG: $MSGOK"
    eval $CMDOK
    return 0
}

# inputs: MSG [MSGOK] [CMDKO]
function RFAILURE
{
    [ "$MODE" != "RUN" ] && "Error: function REVAL only available in RUN mode!" && exit 0
    local MSG="$1"
    local MSGKO="failure!"
    local CMDKO=""
    if [ $# -eq 2 ] ; then
        MSGKO="$2"
    elif [ $# -eq 3 ] ; then
        MSGKO="$2"
        CMDKO="$3"
    fi
    ECHORED "⚠ $MSG: $MSGKO"
    eval $CMDKO
    return 1
}

# inputs: MSG [MSGOK MSGKO] [CMDOK CMDKO]
function REVAL
{
    local RET=$?
    [ "$MODE" != "RUN" ] && "Error: function REVAL only available in RUN mode!" && exit 0
    local MSG="$1"
    local MSGOK="success."
    local MSGKO="failure!"
    local CMDOK=""
    local CMDKO=""
    if [ $# -eq 3 ] ; then
        MSGOK=$2
        MSGKO=$3
    elif [ $# -eq 5 ] ; then
        MSGOK=$2
        MSGKO=$3
        CMDOK=$4
        CMDKO=$5
    fi
    if [ $RET -eq 0 ] ; then
        RSUCCESS "$MSG" "$MSGOK" "$CMDOK"
    else
        RFAILURE "$MSG" "$MSGKO" "$CMDKO"
    fi
    return $RET
}

### ENVIRONMENT ###

function CHECKENV
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

function SAVEENV
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

function LOADENV
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

function PRINTENV
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

function DOWNLOAD
{
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

function START_ONLINE
{
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


function START_OFFLINE
{
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
