#!/bin/bash

### Warning: env.sh must be source before to source this script! ###

#########################################################

TRACE()
{
    if [ "$DEBUG" = "1" ] ; then
	echo "+ $@"
	bash -c "$@"
    elif [ "$VERBOSE" = "1" ] ; then
	bash -c "$@"
    else
	bash -c "$@" &> /dev/null
    fi
}

#########################################################

ECHO()
{
  local COMMENT=""
  if [ "$VPL" = "EVALUATE" ] ; then COMMENT="Comment :=>>" ; fi
  echo "${COMMENT}$@"
}

#########################################################

CHECK()
{
    for FILE in "$@" ; do
	[ ! -f $FILE ] && ECHO "⚠ File \"$FILE\" is missing!" && exit 0
    done
}

#########################################################

EXIT()
{
    (( GRADE < 0 )) && GRADE=0
    (( GRADE > 100 )) && GRADE=100
    ECHO "-GRADE" && ECHO "$GRADE / 100"
    if [ "$VPL" = "EVALUATE" ] ; then echo "Grade :=>> $GRADE" ; fi
    if [ "$VPL" = "RUN" ] ; then echo "Use Ctrl+Shift+⇧ / Ctrl+Shift+⇩ to scroll up / down..." ; fi
    exit 0
}

#########################################################

# inputs: CMD TEST BONUS MALUS [[MSGOK MSGKO] CMDOK CMDKO]
# outputs: GRADE
EVAL()
{
    # check input args
    local CMD=$1
    local TEST=$2
    local BONUS=$3
    local MALUS=$4
    local MSGOK="Success."
    local MSGKO="Failure!"
    local CMDOK=""
    local CMDKO=""

    if [ $# -ge 6 ] ; then
	     MSGOK=$5
	      MSGKO=$6
    fi
    if [ $# -eq 8 ] ; then
	     CMDOK=$7
	      CMDKO=$8
    fi

    eval $CMD
    if eval $TEST ; then
	     [ ! -z "$MSGOK" ] && ECHO "✓ $MSGOK [+$BONUS]"
	     GRADE=$((GRADE+BONUS))
	     eval $CMDOK
    else
	     [ ! -z "$MSGKO" ] && ECHO "⚠ $MSGKO [-$MALUS]"
	     GRADE=$((GRADE-MALUS))
	     eval $CMDKO
    fi
}

#########################################################
