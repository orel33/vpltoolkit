#!/usr/bin/env bash

LOG="teacher.log"

####################################################
#                       ECHO                       #
####################################################

# TODO: use tput
BLUE='\033[34m'
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
NC='\033[0m'    # no color

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


function ECHOBLUE()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Comment :=>>$@"
    else
        echo -n -e "${BLUE}" && echo -n "$@" && echo -e "${NC}"
    fi
}

function ECHOGREEN()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Comment :=>>$@"
    else
        echo -n -e "${GREEN}" && echo -n "$@" && echo -e "${NC}"
    fi
}

function ECHORED()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Comment :=>>$@"
    else
        echo -n -e "${RED}"  && echo -n "$@" && echo -e "${NC}"
    fi
}

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

function ECHO_TEACHER()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Teacher :=>>$@"
    else
        echo "$@" &>> $RUNDIR/$LOG
    fi
}

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

# inputs: MSG
function WARNING()
{
    local MSG="$1"
    ECHOYELLOW "⚠️ Warning: $MSG"
    return 0
}

# inputs: MSG
function ERROR()
{
    local MSG="$1"
    ECHORED "⛔️ Error: $MSG"
    return 0
}

# inputs: MSG
function CRASH()
{
    local MSG="$1"
    ECHORED "⛔️ Internal Error: $MSG"
    return 0
}

# inputs: MSG
function INFO()
{
    local MSG="$1"
    ECHOBLUE "👉 $MSG" # ➡
}

# inputs: MSG
# return 0
function PRINTOK()
{
    [ $# -ne 1 ] && ECHO "Usage: PRINTOK MSG" && exit 0
    local MSG="$1"
    ECHOGREEN "✔️ $MSG" # 🆗
    return 0
}

# inputs: MSG
# return 0
function PRINTKO()
{
    [ $# -ne 1 ] && ECHO "Usage: PRINTKO MSG" && exit 0
    local MSG="$1"
    ECHORED "❌ $MSG" # ❎
    return 0
}

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

function TITLE()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Teacher :=>> ##############################"
        echo -e "${CL}Comment :=>>-$@"
        echo -e "${CL}Teacher :=>> ##############################"
    else
        ECHOBLUE "######### $@ ##########"
    fi
}

####################################################

function TITLE_TEACHER()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Teacher :=>> ##############################"
        echo -e "${CL}Teacher :=>>-$@"
        echo -e "${CL}Teacher :=>> ##############################"
    fi
}

####################################################
#                        CAT                       #
####################################################

# inputs: FILE [HEAD TAIL]
# return cat status
function CAT()
{
    local FILE="$1"
    if [ $# -eq 1 ] ; then
        HEAD=0
        TAIL=0
        CMD="cat $FILE"
    elif [ $# -eq 3 ] ; then
        HEAD="$2"
        TAIL="$3"
        CMD="(head -n $HEAD ; echo \"...\" ; tail -n $TAIL) < $FILE | sed '\$a\'"
        # the command sed '$a\' append a trailing \n only if needed
    else
        ECHO "Usage: CAT FILE [HEAD TAIL]" && exit 0
    fi
    
    [ ! -f $FILE ] && CRASH "CAT (file not found)" && exit 0
    
    if [ "$MODE" = "EVAL" ] ; then
        # cat $@ |& sed -e 's/^/Comment :=>>/;'
        echo -e "${CL}Teacher :=>>\$ cat $FILE"
        echo "<|--"
        eval "$CMD" |& sed -e 's/^/>/;' # preformated output
        RET=${PIPESTATUS[0]}  # return status of first piped command!
        echo "--|>"
    else
        eval "$CMD"
        RET=${PIPESTATUS[0]}  # return status of first piped command!
    fi
    return $RET
}

####################################################

function CAT_TEACHER()
{
    [ $# -ne 1 ] && ECHO "Usage: CAT_TEACHER FILE" && exit 0
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Teacher :=>>\$ cat $@"
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

# inputs: BASH_CMD_STRING
# return command status
function TRACE()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Teacher :=>>\$ $@"
        echo "<|--"
        # setsid is used for safe exec (setpgid(0,0))
        # TODO: setsid returns different status as bash!
        # bash -c "setsid -w $@" |& sed -e 's/^/>/;' # preformated output
        # setsid -w bash -c "$@" |& sed -e 's/^/>/;' # preformated output
        bash -c "$@" |& sed -e 's/^/>/;' # preformated output
        RET=${PIPESTATUS[0]}  # return status of first piped command!
        echo ; echo "--|>" # FIXME: append this echo only if needed! cf. CAT
        local STATUS=$(STRSTATUS $RET)
        echo -e "${CL}Teacher :=>> Status $RET ($STATUS)"
    else
        # bash -c "setsid -w $@"
        # setsid -w bash -c "$@"
        # EXEC $@
        bash -c "$@"
        RET=$?
    fi
    return $RET
}

####################################################

# inputs: BASH_CMD_STRING
# return command status
function TRACE_TEACHER()
{
    if [ "$MODE" = "EVAL" ] ; then
        echo -e "${CL}Teacher :=>>\$ $@"
        # setsid is used for safe exec (setpgid(0,0))
        # TODO: setsid returns different status as bash!
        # bash -c "setsid -w $@" |& sed -e 's/^/Teacher :=>>/;'
        # setsid -w bash -c "$@" |& sed -e 's/^/Teacher :=>>/;' # preformated output
        bash -c "$@" |& sed -e 's/^/Teacher :=>>/;' # preformated output
        local RET=${PIPESTATUS[0]}  # return status of first piped command!
        local STATUS=$(STRSTATUS $RET)
        echo -e "${CL}Teacher :=>> Status $RET ($STATUS)"
    else
        # bash -c "setsid -w $@" &>> $RUNDIR/$LOG
        # setsid -w bash -c "$@" &>> $RUNDIR/$LOG
        bash -c "$@" &>> $RUNDIR/$LOG
        local RET=$?
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
    [ $? -ne 0 ] && CRASH "PYCOMPUTE (invalid formula)" && cat error && exit 0
    return 0
}

####################################################

# inputs: +/-SCORE|FORMULA
function UPDATE_GRADE()
{
    local SCORE=$1
    local LGRADE=$(PYCOMPUTE "$SCORE")
    GRADE=$(PYCOMPUTE "$GRADE+$LGRADE")
}

####################################################

# inputs: RET MSG SCORE [MSGOK]
# return 0 if OK (RET=0), else return 1
function EVALOK()
{
    local RET=0
    local MSG=""
    local SCORE=0
    local MSGOK=""
    if [ $# -eq 3 ] ; then
        local RET="$1"
        local MSG="$2"
        local SCORE="$3" # TODO: check score is >= 0
    elif [ $# -eq 4 ] ; then
        local RET="$1"
        local MSG="$2"
        local local SCORE="$3"
        local MSGOK="$4"
    else
        ECHO "Usage: EVALOK RET MSG SCORE [MSGOK]" && exit 0
    fi
    [ $RET -ne 0 ] && return 1
    local MSGSCORE=""
    local LGRADE=0
    if [ "$SCORE" != "0" ] ; then
        local LGRADE=$(PYCOMPUTE "$SCORE")
        GRADE=$(PYCOMPUTE "$GRADE+$LGRADE")
        if [ "$NOGRADE" != "1" ] ; then MSGSCORE="[$LGRADE%]" ; fi
    fi
    [ -n "$MSGOK" ] && MSGOK="($MSGOK)"
    PRINTOK "$MSG: success $MSGOK $MSGSCORE"
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
    [ -z "$INFO" ] && INFO=$(STRSTATUS $RET) # default INFO
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
    [ -z "$INFO" ] && INFO="" # default INFO
    [ -n "$INFO" ] && INFO="($INFO)"
    PRINTW "$MSG: warning $INFO $MSGSCORE"
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

# inputs: BASH_COMPILATION_STRING EXPECTED_FILE [BONUS WARNING_MALUS ERROR_MALUS]
# return command status
function COMPILE()
{
    if [ $# -eq 2 ] ; then
        local CMD="$1"
        local EXPECTED="$2"
        local BONUS=0
        local WARNINGMALUS=0
        local ERRORMALUS=0
    elif [ $# -eq 5 ] ; then
        local CMD="$1"
        local EXPECTED="$2"
        local BONUS="$3"          # TODO: check positive
        local WARNINGMALUS="$4"   # TODO: check negative
        local ERRORMALUS="$5"     # TODO: check negative
    else
        ECHO "Usage: COMPILE CMD EXPECTED_FILE [BONUS WARNING_MALUS ERROR_MALUS]" && exit 0
    fi

    local TEMP=$(mktemp)
    bash -c "$CMD" &> $TEMP
    local RET=$?
    ECHO "COMPILE RET=$RET"

    # check errors
    EVALKO $RET "compilation" "$ERRORMALUS" "" && CAT $TEMP && return $RET # error !

    if [ ! -x $EXPECTED ] ; then
        EVALKO 1 "compilation" 0 "expected file \"$EXPECTED\" not found!"
        CAT $TEMP && rm -f $TEMP
        return 1 # error !
    fi

    # if WARNING...
    if [ -s $TEMP ] ; then
        EVALW 1 "compilation" "$WARNINGMALUS"
        CAT $TEMP && rm -f $TEMP
        return 0 # warning
    fi

    EVALOK $RET "compilation" $BONUS
    ECHO "COMPILE OKOKOK"
    rm -f $TEMP

    return 0
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
    [ "$EXPECTED" != "$VERSION" ] && ERROR "Toolkit version $EXPECTED expected (but version \"$VERSION\" found)!" && exit 1
}

function CHECKDOCKER()
{
    local EXPECTED="$1"
    [ "$EXPECTED" != "$DOCKER" ] && ERROR "Docker $EXPECTED expected (but docker \"$DOCKER\" found)!" && exit 1
}

function CHECKFILES()
{
    # TODO: check if it supports filenames with spaces
    for FILE in "$@" ; do
        [ ! -f "$FILE" ] && ERROR "File \"$FILE\" is missing!" && exit 1
    done
}

function CHECKINPUTS()
{
    for FILE in "$@" ; do
        [ ! -f "$RUNDIR/inputs/$FILE" ] && ERROR "Requested input file \"$FILE\" is missing!" && exit 1
    done
}

function CHECKPROGRAMS()
{
    # TODO: check if it supports filenames with spaces
    for PROGRAM in "$@" ; do
        type "$PROGRAM" &> /dev/null
        [ $? -ne 0 ] && ERROR "Program \"$PROGRAM\" is missing!" && exit 1
    done
}

####################################################

# EOF
