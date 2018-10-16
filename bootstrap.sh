#!/bin/bash

function setenv()
{
    # basic environment
    VERSION="1.0"
    [ -z "$MODE" ] && echo "⚠ MODE variable is not defined!" && exit 0
    [ -z "$EXO" ] && echo "⚠ EXO variable is not defined!" && exit 0
    [ -z "$DEBUG" ] && DEBUG=0
    [ -z "$VERBOSE" ] && VERBOSE=0

    # export environment
    rm -f $HOME/env.sh
    echo "VERSION=$VERSION" >> $HOME/env.sh
    echo "MODE=$MODE" >> $HOME/env.sh
    echo "EXO=$MODE" >> $HOME/env.sh
    echo "DEBUG=$DEBUG" >> $HOME/env.sh
    echo "VERBOSE=$VERBOSE" >> $HOME/env.sh

    # print environment
    if [ "$DEBUG" = "1" ] ; then
        cat $HOME/env.sh
    fi
}