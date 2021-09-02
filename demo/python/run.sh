#!/usr/bin/env bash

### initialization
source env.sh || exit 0
source vpltoolkit/toolkit.sh || exit 0
CHECKPROGRAMS "python3" "diff" "grep"
CHECKINPUTS "hello.py"
GRADE=0

### student inputs
cp inputs/hello.py .

### execution
TITLE "Test"
TRACE_TEACHER "python3 hello.py &> hello.out"
TRACE_TEACHER "grep -iq 'hello world! hello.out"
EVAL $? "Test program output" 100 0

EXIT_GRADE
