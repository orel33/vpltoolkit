#!/usr/bin/env bash

# default parameters
RUNDIR=$(mktemp -d)
LOCALDIR=""
REPOSITORY=""
BRANCH="master"
PASSWORD=""
URL=""
SUBDIR=""
INPUTDIR=""
VERBOSE=0
GRAPHIC=0
MODE="RUN"
VPLTOOLKIT="https://github.com/orel33/vpltoolkit.git"
LOCAL=0
DEBUG=0
VERSION="master"    # VPL Toolkit branch
ENTRYPOINT="run.sh"
DOWNLOAD=0

### Docker Support ###

DOCKER=""
DOCKERUSER=""
DOCKERTIMEOUT="1h"  # 1 hour


### USAGE ###

USAGE() {
    echo "Usage: $0 <download> [options] <...>"
    echo "Start VPL Toolkit on localhost."
    echo "select <download> method:"
    echo "    -l <localdir>: copy teacher files from local directory into <rundir>"
    echo "    -r <repository>: download teacher files from remote git repository"
    echo "    -w <url>: download teacher zip archive from remote web site"
    echo "[options]:"
    echo "    -L: use local version of VPL Toolkit"
    echo "    -n <version> : set the branch/version of VPL Toolkit to use (default $VERSION)"
    echo "    -m <mode>: set execution mode to RUN, DEBUG or EVAL (default $MODE)"
    echo "    -g : enable graphic mode (default no)"
    echo "    -d <docker> : set docker image to be used (default, no docker)"
    echo "    -u <dockeruser>: set docker user (-d required)"
    echo "    -b <branch>: checkout a branch from git repository (default $BRANCH, -r required)"
    echo "    -p <password>: unzip teacher archive using a password (-w required)"
    echo "    -s <subdir>: only download teacher files from subdir into <rundir>"
    echo "    -e <entrypoint>: entrypoint shell script (default $ENTRYPOINT)"
    echo "    -i <inputdir>: student input directory"
    echo "    -v: enable verbose mode (default no)"
    echo "    -D: enable debug mode (default no)"
    echo "    -h: help"
    echo "<...>: extra arguments passed to START routine in VPL Toolkit"
    exit 0
}

### PARSE ARGUMENTS ###

GETARGS() {
    while getopts "gr:w:l:s:i:m:d:u:n:b:p:e:DLvh" OPT ; do
        case $OPT in
            g)
                GRAPHIC=1
            ;;
            d)
                DOCKER="$OPTARG"
            ;;
            u)
                DOCKERUSER="$OPTARG"
            ;;
            m)
                grep -w $OPTARG <<< "RUN DEBUG EVAL" &> /dev/null
                [ $? -ne 0 ] && echo "⚠ Error: Invalid option \"-m $OPTARG\"" >&2 && USAGE
                MODE="$OPTARG"
            ;;
            n   )
                VERSION="$OPTARG"
            ;;
            l)
                ((DOWNLOAD++))
                LOCALDIR="$OPTARG"
            ;;
            r)
                ((DOWNLOAD++))
                REPOSITORY="$OPTARG"
            ;;
            w)
                ((DOWNLOAD++))
                URL="$OPTARG"
            ;;
            b)
                BRANCH="$OPTARG"    # FIXME: -r required
            ;;
            p)
                PASSWORD="$OPTARG"  # FIXME: -w required
            ;;
            s)
                SUBDIR="$OPTARG"
            ;;
            i)
                INPUTDIR="$OPTARG"
            ;;
            e)
                ENTRYPOINT="$OPTARG"
            ;;
            L)
                LOCAL=1
            ;;
            D)
                DEBUG=1
            ;;
            v)
                VERBOSE=1
            ;;
            h)
                USAGE
            ;;
            \?)
                USAGE
            ;;
        esac
    done

    [ $DOWNLOAD -eq 0 ] && USAGE
    [ $DOWNLOAD -gt 1 ] && echo "⚠ Error: select only one download method!" >&2 && USAGE
    [ $LOCAL -eq 1 -a "$VERSION" != "master" ] && echo "⚠ Warning: option -n <version> is ignored!" >&2
    [ -z "$DOCKER" -a -n "$DOCKERUSER" ] && echo "⚠ Warning: option -u <dockeruser> is ignored!" >&2
    shift $((OPTIND-1))
    ARGS="$@"
}

############################################################################################
#                                           LOCAL RUN                                      #
############################################################################################

GETARGS $*          # FIXME: it should be $@ ???

if [ $VERBOSE -eq 1 ] ; then
    echo "VPLTOOLKIT=$VPLTOOLKIT"
    echo "LOCAL=$LOCAL"
    echo "VERSION=$VERSION"
    echo "RUNDIR=$RUNDIR"
    echo "LOCALDIR=$LOCALDIR"
    echo "REPOSITORY=$REPOSITORY"
    echo "BRANCH=$BRANCH"
    echo "URL=$URL"
    echo "SUBDIR=$SUBDIR"
    echo "INPUTDIR=$INPUTDIR"
    echo "ARGS=$ARGS"
    echo "GRAPHIC=$GRAPHIC"
    echo "ENTRYPOINT=$ENTRYPOINT"
    echo "VERBOSE=$VERBOSE"
    echo "DEBUG=$DEBUG"
    echo "DOCKER=$DOCKER"
    echo "DOCKERUSER=$DOCKERUSER"
fi

### PULL DOCKER IMAGE ###

TIMEOUT=10
LOG="$RUNDIR/start.log"

# if [ -n "$DOCKER" ] ; then
#     [ -z "$(docker images -q $DOCKER)" ] && echo "⚠ Warning: Docker image \"$DOCKER\" not found! I will pull it..." >&2
#     # TODO: add NOPULL option for local Docker image...
#     if [ $VERBOSE -eq 1 ] ; then
#         docker pull $DOCKER
#     else
#         docker pull $DOCKER &>> $LOG
#     fi
#     RET=$?
#     [ $RET -eq 124 ] && echo "⚠ Error: pulling docker image \"$DOCKER\" (timeout)!" >&2 && exit 1
#     [ $RET -ne 0 ] && echo "⚠ Error: pulling docker image \"$DOCKER\" (failure)!" >&2 && exit 1
# fi

### DOWNLOAD VPL TOOLKIT ###

if [ $LOCAL -eq 0 ] ; then
    ( cd $RUNDIR && timeout $TIMEOUT git clone "$VPLTOOLKIT" --depth 1 -b "$VERSION" --single-branch ) &>> $LOG
    [ $? -ne 0 ] && echo "⚠ Error: Git fails to clone \"$VPLTOOLKIT\" (branch $VERSION)!" >&2 && exit 1
else
    VPLDIR="$(realpath $(dirname $0))"
    [ ! -d "$VPLDIR" ] && echo "⚠ Error: invalid local VPL Toolkit directory  \"$VPLDIR\"!" >&2 && exit 1
    mkdir -p $RUNDIR/vpltoolkit && cp -rf $VPLDIR/* $RUNDIR/vpltoolkit/
fi

source $RUNDIR/vpltoolkit/start.sh || exit 1

### LOCAL ###

if [ -n "$LOCALDIR" ] ; then
    SRCDIR="$LOCALDIR"
    [ -n "$SUBDIR" ] && SRCDIR="$LOCALDIR/$SUBDIR"
    [ ! -d $SRCDIR ] && echo "⚠ Error: invalid path \"$SRCDIR\"!" >&2 && exit 1
    cp -rf $SRCDIR/. $RUNDIR/ &>> $LOG
fi

### REPOSITORY ###

if [ -n "$REPOSITORY" ] ; then
    DOWNLOAD "$REPOSITORY" "$BRANCH" "$SUBDIR"
fi

### WEB ###

if [ -n "$URL" ] ; then
    WGET "$URL" "$SUBDIR" "$PASSWORD"
fi


SHELLCMD="bash"
CMD="cd $RUNDIR && $RUNDIR/vpltoolkit/vpl_execution"

### DOCKER START ###

# CMD="$RUNDIR/$ENTRYPOINT"
# [ ! -f "$CMD" ] && echo "⚠ Error: Entrypoint file \"$CMD\" not found!" && exit 0
# ### shell command

# # [ "$DEBUG" = "1" ] && SHELLCMD="bash -x"
# # [ $GRAPHIC -eq 1 ] && SHELLCMD="xterm -hold -e $SHELLCMD"


function DOCKERCLEAN()
{
    # ( docker container stop -t 1 $DOCKERID &> /dev/null )
    ( docker container rm -f $DOCKERID &> /dev/null )
    echo "Docker $DOCKER terminated."
    # docker container prune -f
    # docker system df
}

function DOCKERRUN()
{
    trap 'DOCKERCLEAN' EXIT
    [ -z "$DOCKERTIMEOUT" ] && echo "⚠ Error: Variable \"DOCKERTIMEOUT\" is not defined!" && exit 0
    [ -z "$(docker images -q $DOCKER)" ] && echo "⚠ Warning: Docker image \"$DOCKER\" not found! I will pull it..."
    docker pull $DOCKER &> /dev/null # FIXME: show progress...
    [ $? -ne 0 ] && echo "⚠ Error: pulling docker image \"$DOCKER\" (failure)!" && exit 1
    # docker image inspect $DOCKER &> output
    # [ $? -ne 0 ] && echo "⚠ Error: Docker image \"$DOCKER\" is required, but not locally installed!" && cat output && exit 0

    # DOCKEROPT="--privileged"
    if [ $GRAPHIC -eq 1 ] ; then
        # DOCKEROPT="$DOCKEROPT -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix"
        XDISPLAY=$(sed -e 's/.*:\(.*\)/\1/' <<< $DISPLAY)
        XSOCK="/tmp/.X11-unix/X$XDISPLAY"
        [ ! -S /tmp/.X11-unix/X$XDISPLAY ] && echo "⚠ Error: X11 socket \"$XSOCK\" not found!" && exit 0
        # [ $GRAPHIC -eq 1 ] && echo "DISPLAY=$DISPLAY"
        # [ $GRAPHIC -eq 1 ] && echo "XSOCK=$XSOCK"
        DOCKEROPT="$DOCKEROPT -e DISPLAY=$DISPLAY -v $XSOCK:$XSOCK"
        # DOCKEROPT="$DOCKEROPT --device=/dev/dri:/dev/dri" # direct rendering
    fi
    if [ -S /var/run/docker.sock ] ; then
        DOCKEROPT="$DOCKEROPT -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker"
    else
        echo "⚠ Warning: /var/run/docker.sock not found!"
    fi
    if [ -e /dev/kvm ] ; then
        DOCKEROPT="$DOCKEROPT --device=/dev/kvm:/dev/kvm"
    else
        echo "⚠ Warning: /dev/kvm not found!"
    fi
    # DOCKEROPT="$DOCKEROPT -v /dev/kvm:/dev/kvm" # failure on moodle, ok at home!?
    # DOCKEROPT="$DOCKEROPT -v /root/stockage:/root/stockage"
    # DOCKEROPT="$DOCKEROPT --rm --stop-signal=SIGTERM --stop-timeout=$DOCKERTIMEOUT" # useless ???
    DOCKERHOSTNAME="pouet"
    DOCKEROPT="$DOCKEROPT -d --rm -w $RUNDIR --hostname $DOCKERHOSTNAME" # detached, auto-remove

    ## 1) DOCKER RUN
    DOCKERID=$(docker run $DOCKEROPT $DOCKER sleep $DOCKERTIMEOUT)
    echo "Run Docker $DOCKER ($DOCKERID)."

    ## 2) DOCKER COPY
    # copy all RUNDIR inside docker...
    docker cp -L $RUNDIR/. $DOCKERID:$RUNDIR &> /dev/null
    [ $? -ne 0 ] && echo "⚠ Warning: fails to copy \"$RUNDIR\" into docker!" && exit 0

    # chown RUNDIR as docker user
    if [ -n "$DOCKERUSER" ] ; then
        docker exec -u root $DOCKERID chown -R $DOCKERUSER:$DOCKERUSER $RUNDIR &> /dev/null
        [ $? -ne 0 ] && echo "⚠ Warning: fails to exec chown \"$DOCKERUSER\" into docker!" && exit 0
    fi

    DOCKERUSEROPT=""
    [ -n "$DOCKERUSER" ] && DOCKERUSEROPT="-u $DOCKERUSER"

    ## 3) DOCKER EXEC 

    if [ $GRAPHIC -eq 0 ] ; then
        docker exec $DOCKERUSEROPT -it $DOCKERID $SHELLCMD -c "$CMD $ARGS"
        [ $DEBUG -eq 1 ] && docker exec $DOCKERUSEROPT -it $DOCKERID bash
    else
        # pkill -9 fluxbox    # FIXME: need to kill fluxbox at VPL Jail entrypoint...
        xterm -T main -hold -e docker exec $DOCKERUSEROPT -it $DOCKERID $SHELLCMD -c "$CMD $ARGS"
        [ $DEBUG -eq 1 ] && xterm -T debug -hold -e docker exec $DOCKERUSEROPT -it $DOCKERID bash
    fi
    docker container stop -t 0 $DOCKERID &> /dev/null

}

### START ###

START_OFFLINE "$INPUTDIR" $ARGS

if [ -n "$DOCKER" ] ; then
    echo "dockerrun"
    DOCKERRUN
    echo "done"
else
    $SHELLCMD -c "$CMD $ARGS"
fi

# ONLINE: vpl_script.sh > start.sh (START) > call vpl_execution > call entrypoint (run.sh)
# OFFLINE: local.sh > start.sh (START) > call vpl_execution > call entrypoint (run.sh)

# EOF
