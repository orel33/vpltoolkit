#!/bin/bash

# echo a command (in green) and execute it (RUN mode only)
function RTRACESAFE
{
    echo "$ $@"
    [ ! -x ./launch ] && make &> /dev/null
    ./launch "$@"
    RET=$?
    if [ $RET -eq 0 ] ; then
        echo "✓ Success."
    else
        echo "⚠ Failure!"
    fi
    return $RET
}

RTRACESAFE "./segfault"
RTRACESAFE "echo hello ; ./segfault"