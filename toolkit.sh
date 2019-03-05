#!/bin/bash

LOG="teacher.log"

####################################################
#                      MISC                        #
####################################################

function CHECKVERSION
{
    local EXPECTED="$1"
    [ "$EXPECTED" != "$VERSION" ] && ECHO "⚠ Error: Toolkit version $EXPECTED expected (but version $VERSION found)!" && exit 0
}

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

####################################################
#                       ECHO                       #
####################################################

BLUE='\033[34m'
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
NC='\033[0m'    # no color


function ECHOBLUE
{
    if [ "$MODE" = "RUN" ] ; then
        echo -n -e "${BLUE}" && echo -n "$@" && echo -e "${NC}"
    else
        echo "Comment :=>>$@"
    fi
}

function ECHOGREEN
{
    if [ "$MODE" = "RUN" ] ; then
        echo -n -e "${GREEN}" && echo -n "$@" && echo -e "${NC}"
    else
        echo "Comment :=>>$@"
    fi
}

function ECHORED
{
    if [ "$MODE" = "RUN" ] ; then
        echo -n -e "${RED}"  && echo -n "$@" && echo -e "${NC}"
    else
        echo "Comment :=>>$@"
    fi
}

function ECHOYELLOW
{
    if [ "$MODE" = "RUN" ] ; then
        echo -n -e "${YELLOW}"  && echo -n "$@" && echo -e "${NC}"
    else
        echo "Comment :=>>$@"
    fi
}

function ECHO
{
    if [ "$MODE" = "RUN" ] ; then
        echo "$@"
    else
        echo "Comment :=>>$@"
    fi
}

function ECHO_TEACHER
{
    if [ "$MODE" = "RUN" ] ; then
        echo "$@" &>> $RUNDIR/$LOG
    else
        echo "Teacher :=>>$@"
    fi
}

####################################################
#                STANDARD PRINT                    #
####################################################

# inputs: MSG
function WARNING
{
    local MSG="$1"
    ECHOYELLOW "⚠️ Warning: $MSG"
    return 0
}

# inputs: MSG
function ERROR
{
    local MSG="$1"
    ECHORED "⛔️ Error: $MSG"
    return 0
}

# inputs: MSG
function INFO
{
    local MSG="$1"
    ECHOBLUE "👉 $MSG" # ➡
}

# inputs: MSG [MSGOK]
# return 0
function PRINTOK
{
    local MSG="$1"
    local MSGOK="success"
    if [ $# -eq 2 ] ; then
        MSGOK="$2"
    fi
    ECHOGREEN "✔️ $MSG: $MSGOK" # 🆗
    return 0
}

# inputs: MSG [MSGKO]
# return 0
function PRINTKO
{
    local MSG="$1"
    local MSGKO="failure"
    if [ $# -eq 2 ] ; then
        MSGKO="$2"
    fi
    # ECHORED "⚠️ $MSG: $MSGKO"
    ECHORED "❌ $MSG: $MSGKO" # ❎ ⛔
    return 0
}

####################################################
#                       TITLE                      #
####################################################

function TITLE
{
    if [ "$MODE" = "EVAL" ] ; then
        echo "Comment :=>>-$@"
    else
        ECHOBLUE "######### $@ ##########"
    fi
}

####################################################
#                        CAT                       #
####################################################

function CAT
{
    if [ "$MODE" = "EVAL" ] ; then
        # cat $@ |& sed -e 's/^/Comment :=>>/;'
        echo "Teacher :=>>$ cat $@"
        echo "<|--"
        cat $@ |& sed -e 's/^/>/;' # preformated output
        RET=$?
        echo "--|>"
    else
        cat $@
        RET=$?
    fi
    return $RET
}

function CAT_TEACHER
{
    RET=0
    if [ "$MODE" = "EVAL" ] ; then
        echo "Teacher :=>>$ cat $@"
        bash -c "cat $@" |& sed -e 's/^/Teacher :=>>/;' # setsid is used for safe exec (setpgid(0,0))
        RET=${PIPESTATUS[0]}  # return status of first piped command!
    else
        cat $@ &>> $RUNDIR/$LOG
        RET=$?
    fi
    return $RET
}

####################################################
#                       TRACE                      #
####################################################

function TRACE
{
    if [ "$MODE" = "EVAL" ] ; then    
        echo "Teacher :=>>$ $@"
        echo "<|--"
        bash -c "setsid -w $@" |& sed -e 's/^/>/;' # preformated output
        RET=${PIPESTATUS[0]}  # return status of first piped command!
        echo "--|>"
        echo "Teacher :=>> Status $RET"
    else
        bash -c "setsid -w $@"
        RET=$?
    fi
    return $RET
}

function TRACE_TEACHER
{
    if [ "$MODE" = "EVAL" ] ; then    
        echo "Teacher :=>>$ $@"
        bash -c "setsid -w $@" |& sed -e 's/^/Teacher :=>>/;' # setsid is used for safe exec (setpgid(0,0))
        RET=${PIPESTATUS[0]}  # return status of first piped command!
        echo "Teacher :=>> Status $RET"
    else
        bash -c "setsid -w $@" &>> $RUNDIR/$LOG
        RET=$?
    fi
    return $RET
}

####################################################
#                      EVAL                        #
####################################################

# inputs: FORMULA
function PYCOMPUTE
{
    local FORMULA="$1"
    python3 -c "print(\"%+.2f\" % ($FORMULA))"
    return $?
}

# inputs: MSG SCORE [MSGOK]
# return 0
function GRADEOK
{
    local MSG=""
    local SCORE=0
    local MSGOK="success"
    if [ $# -eq 2 ] ; then
        MSG="$1"
        SCORE="$2" # TODO: check score is >= 0
    elif [ $# -eq 3 ] ; then
        MSG="$1"
        SCORE="$2"
        MSGOK="$3"
    else
        ECHO "Usage: GRADEOK MSG SCORE [MSGOK]" && exit 0
    fi
    local MSGSCORE=""
    local LGRADE=0
    if [ "$SCORE" != "0" ] ; then
        LGRADE=$(python3 -c "print(\"%+.2f\" % ($SCORE))") # it must be positive
        GRADE=$(python3 -c "print($GRADE+$LGRADE)")
        if [ "$NOGRADE" != "1" ] ; then MSGSCORE="[$LGRADE%]" ; fi
    fi
    PRINTOK "$MSG" "$MSGOK $MSGSCORE"
    [ "$SCORE" != "0" ] && ECHO_TEACHER "Update Grade: $LGRADE%"
    return 0
}

# inputs: MSG SCORE [MSGKO]
# return 0
function GRADEKO
{
    local MSG=""
    local SCORE=0
    local MSGKO="failure"
    if [ $# -eq 2 ] ; then
        MSG="$1"
        SCORE="$2" # TODO: check score is <= 0
    elif [ $# -eq 3 ] ; then
        MSG="$1"
        SCORE="$2"
        MSGKO="$3"
    else
        ECHO "Usage: GRADEKO MSG SCORE [MSGKO]" && exit 0
    fi
    local MSGSCORE=""
    local LGRADE=0
    if [ "$SCORE" != "0" ] ; then
        LGRADE=$(python3 -c "print(\"%+.2f\" % ($SCORE))") # it must be negative
        GRADE=$(python3 -c "print($GRADE+$LGRADE)")
        if [ -z "$NOGRADE" ] ; then MSGSCORE="[$LGRADE%]" ; fi
    fi
    PRINTKO "$MSG" "$MSGKO $MSGSCORE"
    [ "$SCORE" != "0" ] && ECHO_TEACHER "Update Grade: $LGRADE%"
    return 0
}

# inputs: MSG SCORE [MSGOK MSGKO]
# global inputs: $GRADE $?
# return: $?
function EVAL
{

    local RET=$?
    local MSG=""
    local SCORE=0
    local MSGOK="success"
    local MSGKO="failure"
    if [ $# -eq 2 ] ; then
        MSG="$1"
        SCORE="$2"
    elif [ $# -eq 4 ] ; then
        MSG="$1"
        SCORE="$2"
        MSGOK="$3"
        MSGKO="$4"
    else
        ECHO "Usage: EVAL MSG SCORE [MSGOK MSGKO]" && exit 0
    fi
    if [ $RET -eq 0 ] ; then
        GRADEOK "$MSG" "$SCORE" "$MSGOK"
    else
        GRADEKO "$MSG" "$SCORE" "$MSGKO"
    fi
    return $RET
}

# inputs: [GRADE]
function EXIT_GRADE
{
    [ -z "$GRADE" ] && GRADE=0
    [ $# -eq 1 ] && GRADE=$1
    GRADE=$(python3 -c "print(0 if $GRADE < 0 else round($GRADE))")
    GRADE=$(python3 -c "print(100 if $GRADE > 100 else round($GRADE))")
    if [ "$NOGRADE" != "1" ] ; then
        ECHO "-GRADE" && ECHO "$GRADE%"
        if [ "$MODE" = "EVAL" ] ; then echo "Grade :=>> $GRADE" ; fi
    else
        ECHO_TEACHER "GRADE: $GRADE%"
    fi
    # if [ "$MODE" = "RUN" ] ; then echo "👉 Use Ctrl+Shift+⇧ / Ctrl+Shift+⇩ to scroll up / down..." ; fi
    exit 0
}

# EOF
