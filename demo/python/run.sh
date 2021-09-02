#!/usr/bin/env bash

### initialization
source env.sh || exit 0
source vpltoolkit/toolkit.sh || exit 0
CHECKPROGRAMS "python3" "diff" "grep"
CHECKINPUTS "hello.py"
GRADE=0

### student inputs
cp inputs/hello.py .

### run mode
if [ $MODE = "RUN" ] ; then
    TITLE "Run"
    INFO "python3 hello.py"
    TRACE "python3 hello.py"
fi

### debug mode
if [ $MODE = "DEBUG" ] ; then
    TITLE "Debug"
    ERROR "not available."
fi

### eval mode
if [ $MODE = "EVAL" ] ; then
    TITLE "Eval"
    TRACE_TEACHER "python3 hello.py &> hello.out"
    TRACE_TEACHER "grep -iq 'hello world' hello.out"
    EVAL $? "Test your program output" 100 0
fi


EXIT_GRADE
