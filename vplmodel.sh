#!/bin/bash


### ENVIRONMENT ###

VERSION="1.0"

function vplmodel_checkenv()
{
    # basic environment
    [ -z "$VERSION" ] && echo "⚠ MODE variable is not defined!" && exit 0
    [ -z "$MODE" ] && echo "⚠ MODE variable is not defined!" && exit 0
    [ -z "$REPOSITORY" ] && echo "⚠ REPOSITORY variable is not defined!" && exit 0
    [ -z "$EXO" ] && echo "⚠ EXO variable is not defined!" && exit 0
    # [ -z "$DEBUG" ] && echo "⚠ DEBUG variable is not defined!" && exit 0
    # [ -z "$VERBOSE" ] && echo "⚠ VERBOSE variable is not defined!" && exit 0
    [ -z "$DEBUG" ] && DEBUG=0
    [ -z "$VERBOSE" ] && VERBOSE=0

}

function vplmodel_saveenv()
{
    # export environment
    rm -f $HOME/env.sh
    echo "VERSION=$VERSION" >> $HOME/env.sh
    echo "MODE=$MODE" >> $HOME/env.sh
    echo "REPOSITORY=$REPOSITORY" >> $HOME/env.sh
    echo "EXO=$EXO" >> $HOME/env.sh
    echo "DEBUG=$DEBUG" >> $HOME/env.sh
    echo "VERBOSE=$VERBOSE" >> $HOME/env.sh
}

function vplmodel_loadenv()
{
    [ ! -f $HOME/env.sh ] && echo "⚠ File \"env.sh\" missing!" && exit 0
    source $HOME/env.sh
}

function vplmodel_printenv()
{
    if [ "$DEBUG" = "1" ] ; then
        cat $HOME/env.sh | grep -v "REPOSITORY"
    fi
}

### DOWNLOAD ###

# TODO: add wget method

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

function vplmodel_download() {
    local EXO=$1
    START=$(date +%s.%N)
    vplmodel_clone $REPOSITORY
    vplmodel_checkout $EXO
    END=$(date +%s.%N)
    TIME=$(python -c "print(int(($END-$START)*1E3))") # in ms
    echo "Download $EXO in $TIME ms"
}

### EXECUTION ###

function vplmodel_start() {
    vplmodel_checkenv
    vplmodel_download $EXO
    vplmodel_saveenv
    cp vplmodel/vpl_execution .
    chmod +x vpl_execution
    # => implicit execution of vpl_execution
}