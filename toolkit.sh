#!/usr/bin/env bash

####################################################
#                    CONSTANTS                     #
####################################################

LOG="teacher.log"
MAXCHAR=100000       # max char on standard output

####################################################
#                       ECHO                       #
####################################################

BLUE='\033[34m'
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
BB='\033[40m'   # black background
NC='\033[0m'    # no color

# FIXME: avoid to use tput?
# TODO: check the problem of TERM with tput... if not defined
# useful for tput, else use tput -Txterm-256color
[ -z "$TERM" ] && export TERM="xterm-256color"

# BLACK=$(tput setaf 0)   # black
# RED=$(tput setaf 1)     # red
# GREEN=$(tput setaf 2)   # green
# BLUE=$(tput setaf 4)    # blue
# YELLOW=$(tput setaf 3)  # yellow
# NC=$(tput sgr0)         # no color

# clear line
CEOL=$(tput el)       # tput requires package "ncurses-bin"
# CL="\r${CEOL}"
CL=""

####################################################

function ECHOBLUE()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Comment :=>>$@"
    else
        echo -n -e "${BLUE}" && echo -n "$@" && echo -e "${NC}"
    fi
}

####################################################

function ECHOGREEN()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Comment :=>>$@"
    else
        echo -n -e "${GREEN}" && echo -n "$@" && echo -e "${NC}"
    fi
}

####################################################

# # green over Black Backround
# function ECHOGREENBB()
# {
#     if [ "$MODE" = "EVAL" ] ; then
#         echo -e "${CL}Comment :=>>$@"
#     else
#         echo -n -e "${BB}${GREEN}" && echo -n "$@" && echo -e "${NC}"
#     fi
# }

####################################################

function ECHORED()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Comment :=>>$@"
    else
        echo -n -e "${RED}"  && echo -n "$@" && echo -e "${NC}"
    fi
}

####################################################

function ECHOYELLOW()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Comment :=>>$@"
    else
        echo -n -e "${YELLOW}"  && echo -n "$@" && echo -e "${NC}"
    fi
}

####################################################

function ECHO()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Comment :=>>$@"
    else
        echo "$@"
    fi
}

####################################################

function ECHO_TEACHER()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Teacher :=>>$@"
    else
        echo "$@" &>> $RUNDIR/$LOG
    fi
}

####################################################

function ECHO_DEBUG()
{
    if [ "$DEBUG" = "1" ] ; then
        if [ "$MODE" = "EVAL" ] ; then
            echo -e "${CL}Debug :=>>$@"
        else
            echo "[debug] $@"
        fi
    fi
}

####################################################
#                STANDARD PRINT                    #
####################################################

# inputs: MSG
function PRE()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Comment :=>>>$@"
    else
        echo "$@"
    fi
}

####################################################

# inputs: MSG
function WARNING()
{
    local MSG="$1"
    ECHOYELLOW "⚠️ Warning: $MSG"
    return 0
}

####################################################

# inputs: MSG
function ERROR()
{
    local MSG="$1"
    ECHORED "⛔️ Error: $MSG"
    return 0
}

####################################################

# inputs: MSG
function CRASH()
{
    local MSG="$1"
    ECHORED "⛔️ Internal Error: $MSG"
    return 0
}

####################################################

# inputs: MSG
function INFO()
{
    local MSG="$1"
    ECHOBLUE "👉 $MSG"
}

####################################################

# inputs: MSG
function MEMO()
{
    local MSG="$1"
    ECHO "📝 $MSG"
}

####################################################

# inputs: MSG
# return 0
function PRINTOK()
{
    [ $# -ne 1 ] && ECHO "Usage: PRINTOK MSG" && exit 0
    local MSG="$1"
    ECHOGREEN "✔️ $MSG" # 🆗
    return 0
}

# FIXME: le green check "✔️" déborde sur le caractère suivant quand il est affiché dans un terminal... cherché un plus petit check ✓

####################################################

# inputs: MSG
# return 0
function PRINTKO()
{
    [ $# -ne 1 ] && ECHO "Usage: PRINTKO MSG" && exit 0
    local MSG="$1"
    ECHORED "❌ $MSG" # ❎
    return 0
}

####################################################

# print warning message
# inputs: MSG
# return 0
function PRINTW()
{
    [ $# -ne 1 ] && ECHO "Usage: PRINTW MSG" && exit 0
    local MSG="$1"
    ECHOYELLOW "⚠️ $MSG"
    return 0
}

####################################################
#                       TITLE                      #
####################################################

# print title
# inputs: TITLE [SCORE]
# return 0

function TITLE()
{
    local THETITLE="$1"
    if [ $# -eq 2 -a "$2" != "0" ] ; then THETITLE="$1 /$2" ; fi
    
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Comment :=>>"
        echo -e "${CL}Teacher :=>> ##############################"
        echo -e "${CL}Comment :=>>-$THETITLE"
        echo -e "${CL}Teacher :=>> ##############################"
        echo -e "${CL}Comment :=>>"
    else
        ECHO
        ECHOBLUE "######### $THETITLE ##########"
        ECHO
    fi
}

####################################################

function TITLE_TEACHER()
{
    [ $# -ne 1 ] && ECHO "Usage: TITLE_TEACHER MSG" && exit 0
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Comment :=>>"
        echo -e "${CL}Teacher :=>> ##############################"
        echo -e "${CL}Teacher :=>>-$1"
        echo -e "${CL}Teacher :=>> ##############################"
        echo -e "${CL}Comment :=>>"
    fi
}

####################################################
#                        CAT                       #
####################################################

# Tips: the command sed '$a\' append a trailing \n only if needed...
# preformat symbol: > ▷ ⇶ ⤷ 〉 ———

# inputs: FILE [HEAD [TAIL]]
# return cat status
function CAT()
{
    local FILE="$1"
    [ ! -f $FILE ] && CRASH "CAT (file not found)" && exit 0
    local CMD="cat $FILE"
    local NLINES=$(cat $FILE | wc -l)
    
    if [ $# -eq 1 ] ; then
        local HEAD="$NLINES"
        local TAIL="$NLINES"
        elif [ $# -eq 2 ] ; then
        local HEAD="$2"
        local TAIL="$2"
        elif [ $# -eq 3 ] ; then
        local HEAD="$2"
        local TAIL="$3"
    else
        ECHO "Usage: CAT FILE [HEAD [TAIL]]" && exit 0
    fi
    
    local WLINES=$(($HEAD+$TAIL))
    if (($WLINES < $NLINES)) ; then
        local CMD="(head -n $HEAD ; echo \"...\" ; tail -n $TAIL) < $FILE"
    fi
    
    if [ "$MODE" = "EVAL" ] ; then
        # cat $@ |& sed -e 's/^/Comment :=>>/;'
        echo -e "${CL}Teacher :=>>\$ cat $FILE"
        echo "<|--"
        eval "$CMD" |& sed -e 's/^/>/;' |& sed '$a\' # preformated output
        # eval "$CMD" |& sed -e 's/^/———/;' | sed '$a\'
        local RET=${PIPESTATUS[0]}  # return status of first piped command!
        echo "--|>"
    else
        eval "$CMD" | sed '$a\'
        local RET=${PIPESTATUS[0]}  # return status of first piped command!
    fi
    
    return $RET
}

####################################################

function CAT_TEACHER()
{
    [ $# -ne 1 ] && ECHO "Usage: CAT_TEACHER FILE" && exit 0
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Teacher :=>>\$ cat $@"
        bash -c "cat $@" |& sed -e 's/^/Teacher :=>>/;' |& sed '$a\'
        local RET=${PIPESTATUS[0]}  # return status of first piped command!
    else
        cat $@ &>> $RUNDIR/$LOG
        local RET=$?
    fi
    return $RET
}

####################################################

function CAT_REPORT()
{
    [ $# -ne 1 ] && ECHO "Usage: CAT_REPORT FILE" && exit 0
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Report :=>>\$ cat $@"
        bash -c "cat $@" |& sed -e 's/^/Report :=>>/;' |& sed '$a\'
        local RET=${PIPESTATUS[0]}  # return status of first piped command!
    else
        cat $@ &>> $RUNDIR/$LOG
        local RET=$?
    fi
    return $RET
}

####################################################
#                       TRACE                      #
####################################################

# silent execution
# ( bash -c "sleep 5 ; exit 124" & wait $! ; exit $? ) &> /dev/null ; echo $?

# inputs: BASH_CMD_STRING
# return command status
function EXEC()
{
    # FIXME: only work for a simple command without subshells...
    # TODO: use disown command to detach command in order to avoid dirty error messages printed by bash
    # TODO: use safe EXEC() in TRACE()
    
    # run redirection in a subshell for safety
    (
        exec 30>&2
        exec 2> /dev/null
        ( bash -c "$@" ) 2>&30
        RET=$?
        exec 2>&30
        exit $RET
    )
    return $?
}



####################################################

# inputs: bash_return_status
function STRSTATUS()
{
    local STATUS=$1
    if (( $STATUS == 0 )) ; then
        echo "EXIT_SUCCESS"
        elif (( $STATUS == 1 )) ; then
        echo "EXIT_FAILURE"
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

# TODO: Use "set -o pipefail ; cmd1 | cmd2" inside TRACE() implementation.

# If pipefail is enabled, the pipeline's return status is the value of the  last
# (rightmost)  command  to exit with a non-zero status, or zero if all commands
# exit successfully. The shell waits for all commands in the pipeline to
# terminate before returning a value.

####################################################

# TODO: limit memory to run command using `ulimit -v MAXMEM` in subshell

# inputs: BASH_CMD_STRING [TIMEOUT]
# return command status
function TRACE()
{
    local TRACECMD="$1"
    local TRACETIMEOUT=0        # no timeout
    [ $# -eq 2 ] && local TRACETIMEOUT=$2
    if [ $# -gt 2 ] ; then
        ECHO "Usage: TRACE BASH_CMD_STRING [TIMEOUT]" && exit 0
    fi
    
    # FIXME: should I really timeout all piped subcommands?
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Teacher :=>>\$ $TRACECMD"
        echo "<|--"
        timeout $TRACETIMEOUT bash -c "$TRACECMD" |& timeout $TRACETIMEOUT head -c $MAXCHAR |& timeout $TRACETIMEOUT sed -e 's/^/>/;' |& timeout $TRACETIMEOUT sed '$a\'  # preformated output
        RET=${PIPESTATUS[0]}  # return status of first piped command!
        echo "--|>"
        local STATUS=$(STRSTATUS $RET)
        echo -e "${CL}Teacher :=>> Status $RET ($STATUS)"
    else
        timeout $TRACETIMEOUT bash -c "$TRACECMD" |& timeout $TRACETIMEOUT head -c $MAXCHAR
        local RET=${PIPESTATUS[0]}  # return status of first piped command!
    fi
    return $RET
}

####################################################

# TODO: limit memory to run command using `ulimit -v MAXMEM` in subshell

# inputs: BASH_CMD_STRING [TIMEOUT]
# return command status
function TRACE_TEACHER()
{
    local TRACECMD="$1"
    local TRACETIMEOUT=0        # no timeout
    [ $# -eq 2 ] && local TRACETIMEOUT=$2
    if [ $# -gt 2 ] ; then
        ECHO "Usage: TRACE_TEACHER BASH_CMD_STRING [TIMEOUT]" && exit 0
    fi
    
    # FIXME: should I really timeout all piped subcommands?
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Teacher :=>>\$ $TRACECMD"
        timeout $TRACETIMEOUT bash -c "$TRACECMD" |& timeout $TRACETIMEOUT head -c $MAXCHAR |& timeout $TRACETIMEOUT sed -e 's/^/Teacher :=>>/;' |& timeout $TRACETIMEOUT sed '$a\' # preformated output
        local RET=${PIPESTATUS[0]}  # return status of first piped command!
        local STATUS=$(STRSTATUS $RET)
        echo -e "${CL}Teacher :=>> Status $RET ($STATUS)"
    else
        timeout $TRACETIMEOUT bash -c "$TRACECMD" |& timeout $TRACETIMEOUT head -c $MAXCHAR &>> $RUNDIR/$LOG
        local RET=${PIPESTATUS[0]}  # return status of first piped command!
    fi
    return $RET
}

####################################################
#                     WAIT                         #
####################################################

# https://stackoverflow.com/questions/238073/how-to-add-a-progress-bar-to-a-shell-script

# wait a background process with a progress bar (spinner)
# inputs: PID MSG
# return command status
function WAIT()
{
    PID=$1
    MSG=$2
    local CEOL=$(tput el)       # tput requires package "ncurses-bin"
    local CL="\r${CEOL}"        # clear line
    local SPINNER='/-\|'
    if [ "$MODE" = "RUN" -o "$MODE" = "DEBUG" ] ; then
        while kill -0 $PID 2> /dev/null; do
            for i in $(seq 0 3) ; do
                echo -ne "${CL}$MSG ${SPINNER:$i:1}"
                sleep 0.1
            done
        done
    fi
    wait $PID &> /dev/null
    RET=$?
    if [ "$MODE" = "RUN" -o "$MODE" = "DEBUG" ] ; then
        echo -ne "${CL}"        # clear line
    fi
    ECHO_TEACHER "$MSG"
    return $RET
}

####################################################
#                      EVAL                        #
####################################################

# inputs: FORMULA
function PYCOMPUTE()
{
    local FORMULA="$1"
    python3 -c "print(\"%+.2f\" % ($FORMULA))" 2> error
    [ $? -ne 0 ] && CRASH "PYCOMPUTE \"$FORMULA\"" && return 1
    return 0
}

####################################################

# inputs: +/-SCORE|FORMULA
function UPDATE_GRADE()
{
    local SCORE=$1
    local LGRADE=$(PYCOMPUTE "$SCORE")
    GRADE=$(PYCOMPUTE "$GRADE+$LGRADE")
    return 0
}

####################################################

# inputs: RET MSG SCORE [INFO]
# return 0 if OK (RET=0), else return 1
function EVALOK()
{
    local RET=0
    local MSG=""
    local SCORE=0
    local INFO=""
    if [ $# -eq 3 ] ; then
        local RET="$1"
        local MSG="$2"
        local SCORE="$3" # TODO: check score is >= 0
        elif [ $# -eq 4 ] ; then
        local RET="$1"
        local MSG="$2"
        local SCORE="$3"
        local INFO="$4"
    else
        ECHO "Usage: EVALOK RET MSG SCORE [INFO]" && exit 0
    fi
    [ $RET -ne 0 ] && return 1
    local MSGSCORE=""
    local LGRADE=0
    if [ "$SCORE" != "0" ] ; then
        local LGRADE=$(PYCOMPUTE "$SCORE")
        GRADE=$(PYCOMPUTE "$GRADE+$LGRADE")
        if [ "$NOGRADE" != "1" ] ; then MSGSCORE="[$LGRADE%]" ; fi
    fi
    [ -n "$INFO" ] && INFO="($INFO)"
    PRINTOK "$MSG: success $INFO $MSGSCORE"
    return 0
}

####################################################

# inputs: RET MSG SCORE [INFO]
# return 0 if KO (RET!=0), else return 1
function EVALKO()
{
    local RET=0
    local MSG=""
    local SCORE=0
    local INFO=""
    if [ $# -eq 3 ] ; then
        local RET="$1"
        local MSG="$2"
        local SCORE="$3" # TODO: check score is <= 0
        elif [ $# -eq 4 ] ; then
        local RET="$1"
        local MSG="$2"
        local SCORE="$3"
        local INFO="$4"
    else
        ECHO "Usage: EVALKO RET MSG SCORE [INFO]" && exit 0
    fi
    [ $RET -eq 0 ] && return 1
    local MSGSCORE=""
    local LGRADE=0
    if [ "$SCORE" != "0" ] ; then
        local LGRADE=$(PYCOMPUTE "$SCORE")
        GRADE=$(PYCOMPUTE "$GRADE+$LGRADE")
        if [ -z "$NOGRADE" ] ; then MSGSCORE="[$LGRADE%]" ; fi
    fi
    # [ -z "$INFO" ] && INFO=$(STRSTATUS $RET) # TODO: when to use default status as INFO?
    [ -n "$INFO" ] && INFO="($INFO)"
    PRINTKO "$MSG: failure $INFO $MSGSCORE"
    return 0
}

####################################################

# inputs: RET MSG SCORE [INFO]
# return 0 if RET!=0, else return 1
function EVALW()
{
    local RET=0
    local MSG=""
    local SCORE=0
    local INFO=""
    if [ $# -eq 3 ] ; then
        local RET="$1"
        local MSG="$2"
        local SCORE="$3" # TODO: check score is <= 0
        elif [ $# -eq 4 ] ; then
        local RET="$1"
        local MSG="$2"
        local SCORE="$3"
        local INFO="$4"
    else
        ECHO "Usage: EVALW RET MSG SCORE [INFO]" && exit 0
    fi
    [ $RET -eq 0 ] && return 1
    local MSGSCORE=""
    local LGRADE=0
    if [ "$SCORE" != "0" ] ; then
        local LGRADE=$(PYCOMPUTE "$SCORE")
        GRADE=$(PYCOMPUTE "$GRADE+$LGRADE")
        if [ -z "$NOGRADE" ] ; then MSGSCORE="[$LGRADE%]" ; fi
    fi
    [ -n "$INFO" ] && INFO="($INFO)"
    PRINTW "$MSG: warning $INFO $MSGSCORE"
    return 0
}

####################################################

# inputs: MSG SCORE
# return 0
function EVALMSG()
{
    local MSG="$1"
    local SCORE="$2"
    if [ $# -ne 2 ] ; then
        ECHO "Usage: EVALMSG MSG SCORE" && exit 0
    fi
    local MSGSCORE=""
    local LGRADE=0
    if [ "$SCORE" != "0" ] ; then
        local LGRADE=$(PYCOMPUTE "$SCORE")
        GRADE=$(PYCOMPUTE "$GRADE+$LGRADE")
        if [ "$NOGRADE" != "1" ] ; then MSGSCORE="[$LGRADE%]" ; fi
    fi
    INFO "$MSG $MSGSCORE"
    return 0
}

####################################################

# inputs: RET MSG [BONUS MALUS [MSGOK MSGKO]]
# return: $RET
function EVAL()
{
    local RET="$1"
    local MSG=""
    local BONUS=0
    local MALUS=0
    local MSGOK=""
    local MSGKO=""
    if [ $# -eq 2 ] ; then
        MSG="$2"
        elif [ $# -eq 4 ] ; then
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
        ECHO "Usage: EVAL RET MSG [BONUS MALUS [MSGOK MSGKO]]" && exit 0
    fi
    if [ $RET -eq 0 ] ; then
        EVALOK "$RET" "$MSG" "$BONUS" "$MSGOK"
    else
        EVALKO "$RET" "$MSG" "$MALUS" "$MSGKO"
    fi
    return $RET
}

####################################################

# inputs: [GRADE]
function EXIT_GRADE()
{
    [ -z "$GRADE" ] && GRADE=0
    [ $# -eq 1 ] && GRADE=$1
    GRADE=$(python3 -c "print(0 if $GRADE < 0 else round($GRADE))")
    GRADE=$(python3 -c "print(100 if $GRADE > 100 else round($GRADE))")
    if [ "$NOGRADE" != "1" ] ; then
        # ECHO "-GRADE" && ECHO "$GRADE%"
        if [ "$MODE" = "EVAL" ] ; then echo -e "${CL}Grade :=>> $GRADE" ; fi
    else
        ECHO_TEACHER "GRADE: $GRADE%"
    fi
    exit 0
}

####################################################
#                      CHECK                       #
####################################################

function CHECKVERSION()
{
    local EXPECTED="$1"
    [ "$EXPECTED" != "$VERSION" ] && ERROR "Toolkit version $EXPECTED expected (but version \"$VERSION\" found)!" && return 1
    return 0
}

####################################################

function CHECKFILES()
{
    # TODO: check if it supports filenames with spaces
    for FILE in "$@" ; do
        [ ! -f "$FILE" ] && ERROR "File \"$FILE\" is missing!" && return 1
    done
    return 0
}

####################################################

function CHECKINPUTS()
{
    for FILE in "$@" ; do
        [ ! -f "$RUNDIR/inputs/$FILE" ] && ERROR "Requested input file \"$FILE\" is missing!" && return 1
    done
    return 0
}

####################################################

function CHECKPROGRAMS()
{
    # TODO: check if it supports filenames with spaces
    for PROGRAM in "$@" ; do
        type "$PROGRAM" &> /dev/null
        [ $? -ne 0 ] && ERROR "Program \"$PROGRAM\" is missing!" && return 1
    done
    return 0
}

####################################################

# EOF
