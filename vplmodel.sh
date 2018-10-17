#!/bin/bash

function vplmodel_setenv()
{
    # basic environment
    VERSION="1.0"
    [ -z "$MODE" ] && echo "⚠ MODE variable is not defined!" && exit 0
    [ -z "$REPOSITORY" ] && echo "⚠ REPOSITORY variable is not defined!" && exit 0
    [ -z "$EXO" ] && echo "⚠ EXO variable is not defined!" && exit 0
    [ -z "$DEBUG" ] && DEBUG=0
    [ -z "$VERBOSE" ] && VERBOSE=0
    
    # export environment
    rm -f $HOME/env.sh
    echo "VERSION=$VERSION" >> $HOME/env.sh
    echo "MODE=$MODE" >> $HOME/env.sh
    echo "REPOSITORY=$REPOSITORY" >> $HOME/env.sh
    echo "EXO=$EXO" >> $HOME/env.sh
    echo "DEBUG=$DEBUG" >> $HOME/env.sh
    echo "VERBOSE=$VERBOSE" >> $HOME/env.sh
    
    # print environment
    if [ "$DEBUG" = "1" ] ; then
        cat $HOME/env.sh
    fi
}

function vplmodel_getenv()
{
    [ ! -f $HOME/env.sh ] && echo "⚠ File \"env.sh\" missing!" && exit 0
    source $HOME/env.sh
}

function vplmodel_clone() {
    local REPOSITORY=$1
    [ -z "$REPOSITORY" ] && echo "⚠ REPOSITORY variable is not defined!" && exit 0
    git -c http.sslVerify=false clone -q -n $REPOSITORY --depth 1 GIT
    [ ! $? -eq 0 ] && echo "⚠ GIT clone \"vplmoodle\" failure!" && exit 0
}

function vplmodel_checkout() {
    local CHECKOUT=$1
    cd GIT && git -c http.sslVerify=false checkout HEAD -- $CHECKOUT && cd
    [ ! $? -eq 0 ] && echo "⚠ GIT checkout \"$CHECKOUT\" failure!" && exit 0
}
