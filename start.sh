#!/usr/bin/env bash

VERSION="5.0"
[ -z "$RUNDIR" ] && RUNDIR=$(mktemp -d)
LOG="$RUNDIR/start.log"
TIMEOUT=10

####################################################
#                      MISC                        #
####################################################

# print date in seconds.microseconds
function DATE()
{
    # FIXME: if time > 1mn !!!
    python3 -c "import datetime ; now = datetime.datetime.now() ; print(\"{}.{:06d}\".format(now.second,now.microsecond))"
    return 0
}

####################################################
#                 ENVIRONMENT                      #
####################################################

function CHECKENV()
{
    # basic environment
    [ -z "$VERSION" ] && echo "⚠ Error: VERSION variable is not defined!" >&2 && exit 1
    [ -z "$ONLINE" ] && echo "⚠ Error: ONLINE variable is not defined!" >&2 && exit 1
    [ -z "$MODE" ] && echo "⚠ Error: MODE variable is not defined!" >&2 && exit 1
    [ -z "$RUNDIR" ] && echo "⚠ Error: RUNDIR variable is not defined!" >&2 && exit 1
    [ -z "$GRAPHIC" ] && GRAPHIC=0
    [ -z "$DEBUG" ] && DEBUG=0
    [ -z "$VERBOSE" ] && VERBOSE=0
    [ -z "$ENTRYPOINT" ] && ENTRYPOINT="run.sh"
    [ -z "$ARGS" ] && ARGS=""
    [ -z "$INPUTS" ] && INPUTS=""
    [ -z "$EMAIL" ] && EMAIL="unknown@etu.u-bordeaux.fr"
    return 0
}

####################################################

function SAVEENV()
{
    [ -z "$RUNDIR" ] && echo "⚠ Error: RUNDIR variable is not defined!" >&2 && exit 1
    rm -f $RUNDIR/env.sh
    echo "VERSION=$VERSION" >> $RUNDIR/env.sh
    echo "MODE=$MODE" >> $RUNDIR/env.sh
    echo "ONLINE=$ONLINE" >> $RUNDIR/env.sh
    echo "RUNDIR=$RUNDIR" >> $RUNDIR/env.sh
    echo "GRAPHIC=$GRAPHIC" >> $RUNDIR/env.sh
    echo "DEBUG=$DEBUG" >> $RUNDIR/env.sh
    echo "VERBOSE=$VERBOSE" >> $RUNDIR/env.sh
    echo "ENTRYPOINT=$ENTRYPOINT" >> $RUNDIR/env.sh
    echo "ARGS=\"$ARGS\"" >> $RUNDIR/env.sh
    echo "INPUTS=$INPUTS" >> $RUNDIR/env.sh
    echo "EMAIL=$EMAIL" >> $RUNDIR/env.sh
    return 0
}

####################################################

function LOADENV()
{
    if [ -f $RUNDIR/env.sh ] ; then
        source $RUNDIR/env.sh
        elif [ -f ./env.sh ] ; then
        source ./env.sh
        elif [ -f $HOME/env.sh ] ; then
        source $HOME/env.sh
    else
        echo "⚠ Error: File \"env.sh\" is missing!" >&2 && exit 1
    fi
    return 0
}

####################################################

function PRINTENV()
{
    echo "* SYSTEM=$(lsb_release -d | cut -d: -f2 | tr -d [:space:])"
    echo "* VERSION=$VERSION"
    echo "* ONLINE=$ONLINE"
    echo "* MODE=$MODE"
    echo "* RUNDIR=$RUNDIR"
    echo "* GRAPHIC=$GRAPHIC"
    echo "* DEBUG=$DEBUG"
    echo "* VERBOSE=$VERBOSE"
    echo "* ENTRYPOINT=$ENTRYPOINT"
    echo "* ARGS=\"$ARGS\""
    echo "* INPUTS=$INPUTS"
    echo "* EMAIL=$EMAIL"
    return 0
}

####################################################
#                   DOWNLOAD                       #
####################################################

### DOWNLOAD TEACHER FILES FROM GIT REPOSITORY (and COPY FILES in RUNDIR)
function DOWNLOAD()
{
    if [ $# -eq 1 ] ; then
        local REPOSITORY="$1"
        local BRANCH="master"
        local SUBDIRS=""
    elif [ $# -eq 2 ] ; then
        local REPOSITORY="$1"
        local BRANCH="$2"
        local SUBDIRS=""
    elif [ $# -ge 3 ] ; then
        local REPOSITORY="$1"
        local BRANCH="$2"
        shift
        shift
        local SUBDIRS=("$@")
    else
        echo "⚠ Error: Usage: DOWNLOAD REPOSITORY [BRANCH [SUBDIR] ...]" >&2 && exit 1
    fi

    START=$(DATE)
    [ -z "$RUNDIR" ] && echo "⚠ Error: RUNDIR variable is not defined!" >&2 && exit 1
    mkdir -p $RUNDIR/download
    [ -z "$REPOSITORY" ] && echo "⚠ Error: REPOSITORY variable is not defined!" >&2 && exit 1
    [ -z "$BRANCH" ] && echo "⚠ Error: BRANCH variable is not defined!" >&2 && exit 1
    # git clone (without checkout of HEAD)
    ( timeout $TIMEOUT git -c http.sslVerify=false clone -q -n $REPOSITORY --branch $BRANCH --depth 1 $RUNDIR/download ) &>> $LOG
    RET=$?
    [ $RET -eq 124 ] && echo "⚠ Error: GIT clone repository failure (timeout)!" >&2 && exit 1
    [ $RET -ne 0 ] && echo "⚠ Error: GIT clone repository failure (branch \"$BRANCH\")!" >&2 && exit 1

    # checkout only what is needed
    if [ -n "$SUBDIRS" ] ; then
        ( cd $RUNDIR/download && timeout $TIMEOUT git -c http.sslVerify=false checkout HEAD -- "${SUBDIRS[@]}" ) &>> $LOG
        RET=$?
        [ $RET -eq 124 ] && echo "⚠ Error: GIT checkout failure (timeout)!" >&2 && exit 1
        [ $RET -ne 0 ] && echo "⚠ Error: GIT checkout failure (subdirs: \"$SUBDIRS\")!" >&2 && exit 1
        for SUBDIR in "${SUBDIRS[@]}" ; do
            [ ! -d $RUNDIR/download/$SUBDIR ] && echo "⚠ Error: SUBDIR \"$SUBDIR\" not found!" >&2 && exit 1
            cp -rf $RUNDIR/download/$SUBDIR/. $RUNDIR/ &>> $LOG
        done 
    else
        ( cd $RUNDIR/download && timeout $TIMEOUT git -c http.sslVerify=false checkout HEAD ) &>> $LOG
        RET=$?
        [ $RET -eq 124 ] && echo "⚠ Error: GIT checkout failure (timeout)!" >&2 && exit 1
        [ $RET -ne 0 ] && echo "⚠ Error: GIT checkout failure!" >&2 && exit 1
        cp -rf $RUNDIR/download/. $RUNDIR/ &>> $LOG
    fi
    rm -rf $RUNDIR/download &>> $LOG
    END=$(DATE)
    TIME=$(python3 -c "print(int(($END-$START)*1E3))") # in ms
    [ "$VERBOSE" = "1" ] && echo "Download teacher files in $TIME ms"
    return 0
}

####################################################

### DOWNLOAD TEACHER ARCHIVE (ZIP) FROM A WEB SITE
# TODO: use htaccess login:password instead of zip encryption
function WGET()
{
    if [ $# -eq 1 ] ; then
        local REPOSITORY="$1"
        local SUBDIR=""
        local PASSWORD=""
        elif [ $# -eq 2 ] ; then
        local REPOSITORY="$1"
        local SUBDIR="$2"
        local PASSWORD=""
        elif [ $# -eq 3 ] ; then
        local REPOSITORY="$1"
        local SUBDIR="$2"
        local PASSWORD="$3"
    else
        echo "⚠ Error: Usage: WGET URL [SUBDIR [PASSWORD]]" >&2 && exit 1
    fi

    START=$(DATE)
    mkdir -p $RUNDIR/download
    timeout $TIMEOUT wget -a $LOG -O $RUNDIR/download/teacher.zip "$URL"
    RET=$?
    [ $RET -eq 124 ] && echo "⚠ Error: wget failure (timeout)!" >&2 && exit 1
    [ $RET -ne 0 ] && echo "⚠ Error: wget failure!" >&2 && exit 1
    local OPT=""
    [ -n "$PASSWORD" ] && local OPT="-P $PASSWORD"
    unzip $OPT $RUNDIR/download/teacher.zip -d $RUNDIR/download/teacher &>> $LOG
    [ $? -ne 0 ] && echo "⚠ Error: unzip failure!" >&2 && exit 1
    if [ -n "$SUBDIR" ] ; then
        [ ! -d $RUNDIR/download/teacher/$SUBDIR ] && echo "⚠ Error: SUBDIR \"$SUBDIR\" not found!" >&2 && exit 1
        cp -rf $RUNDIR/download/teacher/$SUBDIR/. $RUNDIR/
    else
        cp -rf $RUNDIR/download/teacher/. $RUNDIR/
    fi
    rm -rf $RUNDIR/download &>> $LOG
    END=$(DATE)
    TIME=$(python3 -c "print(int(($END-$START)*1E3))") # in ms
    [ "$VERBOSE" = "1" ] && echo "Download teacher files in $TIME ms"
    return 0
}

####################################################
#                      START                       #
####################################################

function START_ONLINE()
{
    [ ! $# -ge 0 ] && echo "⚠ Error: Usage: START_ONLINE [...]" >&2 && exit 1
    ARGS="${@:1}"
    [ -z "$RUNDIR" ] && echo "⚠ Error: RUNDIR variable is not defined!" >&2 && exit 1
    [ ! -d $RUNDIR ] && echo "⚠ Error: Bad RUNDIR: \"$RUNDIR\"!" >&2 && exit 1
    ONLINE=1
    [ $(basename $0) == "vpl_run.sh" ] && MODE="RUN"
    [ $(basename $0) == "vpl_debug.sh" ] && MODE="DEBUG"
    [ $(basename $0) == "vpl_evaluate.sh" ] && MODE="EVAL"
    [ -z "$MODE" ] && echo "⚠ Error: MODE variable is not defined!" >&2 && exit 1
    grep -w $MODE <<< "RUN DEBUG EVAL" &> /dev/null
    [ $? -ne 0 ] && echo "⚠ Error: Invalid MODE \"$MODE\"!" >&2 && exit 1
    [ -f  $HOME/vpl_environment.sh ] && source $HOME/vpl_environment.sh
    mkdir -p $RUNDIR/inputs
    # [ ! -z "$VPL_SUBFILES" ] && ( cd $HOME && cp $VPL_SUBFILES $RUNDIR/inputs ) # FIXME: here bug if file contains spaces
    for var in ${!VPL_SUBFILE@} ; do
        # $var => variable name  and ${!var} => variable value
        [ "$var" = "VPL_SUBFILES" ] && continue
        local file="${!var}"
        # decode binary file
        if [ -f "$file.b64" ] ; then
            # echo "⚠ Error: decode file \"$file.b64\""
            base64 -d "$file.b64" > "$file"
            [ ! $? -eq 0 ] && echo "⚠ Error: cannot decode file \"$file.b64\"!"
        fi
        [ ! -f "$file" ] && echo "⚠ Error: input file \"$file\" not found!" && continue
        cp -f "$file" $RUNDIR/inputs &> /dev/null
        [ ! $? -eq 0 ] && echo "⚠ Error: cannot copy input file \"$file\" in inputs directory!"
    done
    rm -rf $RUNDIR/vpltoolkit/.git/ &> /dev/null # for security issue
    # prepare environment
    INPUTS="$RUNDIR/inputs/"
    EMAIL="${VPL_STUDENT_MAIL}"
    CHECKENV
    SAVEENV
    cp $RUNDIR/env.sh $HOME
    cp $RUNDIR/vpltoolkit/toolkit.sh $HOME
    cp $RUNDIR/vpltoolkit/vpl_execution $HOME
    cp $HOME/vpl_environment.sh $RUNDIR/
    cp $HOME/common_script.sh $RUNDIR/
    # graphic session
    [ $GRAPHIC -eq 1 ] && mv $HOME/vpl_execution $HOME/vpl_wexecution
    # print in compilation window
    echo "Start VPL Toolkit in $SECONDS sec..."
    PRINTENV
    # => implicit run of vpl_execution in $HOME
    return 0
}

####################################################

function START_OFFLINE()
{
    [ ! $# -ge 1 ] && echo "⚠ Error: Usage: START_OFFLINE INPUTDIR [...]" >&2 && exit 1
    local INPUTDIR="$1"
    local ARGS="${@:2}"
    [ ! -z "$INPUTDIR" ] && [ ! -d $INPUTDIR ] && echo "⚠ Error: Bad INPUTDIR: \"$INPUTDIR\"!" >&2 && exit 1
    [ -z "$RUNDIR" ] && echo "⚠ Error: RUNDIR variable is not defined!" >&2 && exit 1
    [ ! -d $RUNDIR ] && echo "⚠ Error: Bad RUNDIR: \"$RUNDIR\"!" >&2 && exit 1
    ONLINE=0
    [ -z "$MODE" ] && echo "⚠ Error: MODE variable is not defined!" >&2 && exit 1
    grep -w $MODE <<< "RUN DEBUG EVAL" &> /dev/null
    [ $? -ne 0 ] && echo "⚠ Error: Invalid MODE \"$MODE\"!" >&2 && exit 1
    # prepare inputs
    mkdir -p $RUNDIR/inputs
    cp $INPUTDIR/* $RUNDIR/inputs/ &> /dev/null     # FIXME: error if no inputs
    INPUTS="$RUNDIR/inputs/"
    # prepare environment
    [ -f $INPUTS/vpl_environment.sh ] && source $INPUTS/vpl_environment.sh
    EMAIL="${VPL_STUDENT_MAIL}"
    CHECKENV
    SAVEENV
    rm -rf $RUNDIR/vpltoolkit/.git/ &> /dev/null # for security issue
    echo "Start VPL Toolkit in $SECONDS sec..."
    PRINTENV
    # cd $RUNDIR && $RUNDIR/vpltoolkit/vpl_execution
    # => explicit run of vpl_execution in $RUNDIR
    return 0
}

####################################################

function START()
{
    ONLINE=0
    [ $(basename $0) == "vpl_run.sh" ] && ONLINE=1
    [ $(basename $0) == "vpl_debug.sh" ] && ONLINE=1
    [ $(basename $0) == "vpl_evaluate.sh" ] && ONLINE=1
    ARGS="${@:1}"
    if [ $ONLINE -eq 1 ] ; then START_ONLINE "$ARGS" ; else START_OFFLINE "$ARGS" ; fi
    return 0
}

# EOF
