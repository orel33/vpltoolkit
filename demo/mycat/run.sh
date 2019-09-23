#!/usr/bin/env bash

### initialization
source env.sh || exit 0
source vpltoolkit/toolkit.sh || exit 0
CHECKVERSION "4.0"
CHECKPROGRAMS "gcc" "cat" "diff"
CHECKINPUTS "mycat.c"
GRADE=0

### student inputs
cp inputs/mycat.c .

### compilation
TITLE "COMPILATION"
CFLAGS="-std=c99 -Wall"
WFLAGS="-Wl,--wrap=system"
COMPILE "compilation" "gcc $CFLAGS $WFLAGS mycat.c -o mycat" 0 -10 0 || EXIT_GRADE 0

### execution
TITLE "EXECUTION"
TRACE_TEACHER "echo \"abcdef\" > mycat.in"
TRACE_TEACHER "cat mycat.in | ./mycat > mycat.out"
EVAL $? "run mycat" 0 -10
TRACE_TEACHER "diff -q mycat.in mycat.out"
EVAL $? "test mycat" 100 0 "" "output differs from input"

EXIT_GRADE
