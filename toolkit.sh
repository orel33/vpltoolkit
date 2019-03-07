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

####################################################

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

# inputs: MSG
# return 0
function PRINTOK
{
    [ $# -ne 1 ] && ECHO "Usage: PRINTOK MSG" && exit 0
    local MSG="$1"
    ECHOGREEN "✔️ $MSG" # 🆗
    return 0
}

# inputs: MSG
# return 0
function PRINTKO
{
    [ $# -ne 1 ] && ECHO "Usage: PRINTKO MSG" && exit 0
    local MSG="$1"
    ECHORED "❌ $MSG" # ❎ ⛔
    return 0
}

####################################################
#                       TITLE                      #
####################################################

function TITLE
{
    if [ "$MODE" = "EVAL" ] ; then
        echo "Teacher :=>> ##############################"
        echo "Comment :=>>-$@"
        echo "Teacher :=>> ##############################"
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

####################################################

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
        # setsid is used for safe exec (setpgid(0,0))
        # bash -c "setsid -w $@" |& sed -e 's/^/>/;' # preformated output
        setsid -w bash -c "$@" |& sed -e 's/^/>/;' # preformated output
        RET=${PIPESTATUS[0]}  # return status of first piped command!
        echo ; echo "--|>"
        echo "Teacher :=>> Status $RET"
    else
        # bash -c "setsid -w $@"
        setsid -w bash -c "$@"
        RET=$?
    fi
    return $RET
}

####################################################

function TRACE_TEACHER
{
    if [ "$MODE" = "EVAL" ] ; then
        echo "Teacher :=>>$ $@"
        # setsid is used for safe exec (setpgid(0,0))
        # bash -c "setsid -w $@" |& sed -e 's/^/Teacher :=>>/;'
        setsid -w bash -c "$@" |& sed -e 's/^/Teacher :=>>/;' # preformated output
        RET=${PIPESTATUS[0]}  # return status of first piped command!
        echo "Teacher :=>> Status $RET"
    else
        # bash -c "setsid -w $@" &>> $RUNDIR/$LOG
        setsid -w bash -c "$@" &>> $RUNDIR/$LOG
        RET=$?
    fi
    return $RET
}

####################################################
#                      EVAL                        #
####################################################

# inputs: bash_return_status
function STRSTATUS()
{
    local STATUS=$1
    if (( $STATUS == 0 )) ; then
        echo "return EXIT_SUCCESS"
    elif (( $STATUS == 1 )) ; then
        echo "return EXIT_FAILURE"
    elif (( $STATUS == 124 )) ; then
        echo "timeout"
    elif (( $STATUS > 128 && $STATUS <= 192 )) ; then
        NSIG=$((STATUS-128))
        STRSIG=$(kill -l $NSIG)
        echo "killed by signal $STRSIG"
    else
        echo "return $STATUS"
    fi
}

####################################################

# inputs: FORMULA
function PYCOMPUTE
{
    local FORMULA="$1"
    python3 -c "print(\"%+.2f\" % ($FORMULA))"
    return $?
}

####################################################

# inputs: RET MSG SCORE [MSGOK]
# return 0 if OK (RET=0), else return 1
function EVALOK

    local RET=0
    local MSG=""
    local SCORE=0
    local MSGOK=""
    if [ $# -eq 3 ] ; then
        RET="$1"
        MSG="$2"
        SCORE="$3" # TODO: check score is >= 0
    elif [ $# -eq 4 ] ; then
        RET="$1"
        MSG="$2"
        SCORE="$3"
        MSGOK="$4"
    else
        ECHO "Usage: EVALOK RET MSG SCORE [MSGOK]" && exit 0
    fi
    [ $RET -ne 0 ] && return 1
    local MSGSCORE=""
    local LGRADE=0
    if [ "$SCORE" != "0" ] ; then
        LGRADE=$(python3 -c "print(\"%+.2f\" % ($SCORE))") # it must be positive
        GRADE=$(python3 -c "print($GRADE+$LGRADE)")
        if [ "$NOGRADE" != "1" ] ; then MSGSCORE="[$LGRADE%]" ; fi
    fi
    [ -n "$MSGOK" ] && MSGOK="($MSGOK)"
    PRINTOK "$MSG: success $MSGOK $MSGSCORE"
    # [ "$SCORE" != "0" ] && ECHO_TEACHER "Update Grade: $LGRADE%"
    return 0
}

####################################################

# inputs: RET MSG SCORE [MSGKO]
# return 0 if KO (RET!=0), else return 1
function EVALKO
{
    local RET=0
    local MSG=""
    local SCORE=0
    local MSGKO=""
    if [ $# -eq 3 ] ; then
        RET="$1"
        MSG="$2"
        SCORE="$3" # TODO: check score is <= 0
    elif [ $# -eq 4 ] ; then
        RET="$1"
        MSG="$2"
        SCORE="$3"
        MSGKO="$4"
    else
        ECHO "Usage: EVALKO RET MSG SCORE [MSGKO]" && exit 0
    fi
    [ $RET -eq 0 ] && return 1
    local MSGSCORE=""
    local LGRADE=0
    if [ "$SCORE" != "0" ] ; then
        LGRADE=$(python3 -c "print(\"%+.2f\" % ($SCORE))") # it must be negative
        GRADE=$(python3 -c "print($GRADE+$LGRADE)")
        if [ -z "$NOGRADE" ] ; then MSGSCORE="[$LGRADE%]" ; fi
    fi
    [ -z "$MSGKO" ] && MSGKO=$(STRSTATUS $RET) # default MSGKO
    [ -n "$MSGKO" ] && MSGKO="($MSGKO)"
    PRINTKO "$MSG: failure $MSGKO $MSGSCORE"
    # [ "$SCORE" != "0" ] && ECHO_TEACHER "Update Grade: $LGRADE%"
    return 0
}

####################################################

# inputs: RET MSG BONUS MALUS [MSGOK MSGKO]
# return: $RET
function EVAL
{
    local RET="$1"
    local MSG=""
    local BONUS=0
    local MALUS=0
    local MSGOK=""
    local MSGKO=""
    if [ $# -eq 4 ] ; then
        MSG="$2"
        BONUS="$3"
        MALUS="$4"
    elif [ $# -eq 6 ] ; then
        MSG="$2"
        BONUS="$3"  # TODO: check positive
        MALUS="$4"  # TODO: check negative
        MSGOK="$5"
        MSGKO="$6"
    else
        ECHO "Usage: EVAL RET MSG BONUS MALUS [MSGOK MSGKO]" && exit 0
    fi
    if [ $RET -eq 0 ] ; then
        # [ -z "$MSGOK" ] && MSGOK=$(STRSTATUS $RET) # default MSGOK
        EVALOK "$RET" "$MSG" "$BONUS" "$MSGOK"
    else
        # [ -z "$MSGKO" ] && MSGKO=$(STRSTATUS $RET) # default MSGKO
        EVALKO "$RET" "$MSG" "$MALUS" "$MSGKO"
    fi
    return $RET
}

####################################################

# inputs: [GRADE]
function EXIT_GRADE
{
    [ -z "$GRADE" ] && GRADE=0
    [ $# -eq 1 ] && GRADE=$1
    GRADE=$(python3 -c "print(0 if $GRADE < 0 else round($GRADE))")
    GRADE=$(python3 -c "print(100 if $GRADE > 100 else round($GRADE))")
    if [ "$NOGRADE" != "1" ] ; then
        # ECHO "-GRADE" && ECHO "$GRADE%"
        if [ "$MODE" = "EVAL" ] ; then echo "Grade :=>> $GRADE" ; fi
    else
        ECHO_TEACHER "GRADE: $GRADE%"
    fi
    # if [ "$MODE" = "RUN" ] ; then echo "👉 Use Ctrl+Shift+⇧ / Ctrl+Shift+⇩ to scroll up / down..." ; fi
    exit 0
}

# EOF
