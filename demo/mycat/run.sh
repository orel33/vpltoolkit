#!/bin/bash

### initialization
source env.sh || exit 0
source vpltoolkit/toolkit.sh || exit 0
CHECKVERSION "4.0"
CHECKDOCKER "orel33/mydebian:latest"
GRADE=0

### student inputs
[ ! -f inputs/mycat.c ] && ERROR "Input file mycat.c expected but not found!" && EXIT_GRADE 0
cp inputs/mycat.c .

### compilation
TITLE "COMPILATION"
CFLAGS="-std=c99 -Wall"
WFLAGS="-Wl,--wrap=system"
TRACE "gcc $CFLAGS $WFLAGS mycat.c -o mycat |& tee warnings"
EVALKO $? "compilation" 0 "errors" && EXIT_GRADE 0
[ -x mycat ] && EVALOK $? "compilation" 30 "success"
[ -s warnings ] && EVALKO 1 "compilation" -10 "warnings"

### execution
TITLE "EXECUTION"
TRACE_TEACHER "echo \"abcdef\" > mycat.in"
TRACE_TEACHER "cat mycat.in | ./mycat > mycat.out"
EVAL $? "run mycat" 10 0
TRACE_TEACHER "diff -q mycat.in mycat.out"
EVAL $? "test mycat" 60 0
EXIT_GRADE

# ### run
# CFLAGS="-std=c99 -Wall"
# RTRACE "gcc $CFLAGS mycat.c -o mycat"
# [ ! $? -eq 0 ] && RMALUS "Compilation" && exit 0
# RTRACE "echo \"abcdef\" > mycat.in && cat mycat.in"
# RTRACE "cat mycat.in | ./mycat | tee mycat.out"
# RTRACE "diff mycat.in mycat.out"
# REVAL "Program output" "valid" "invalid"

### compilation
# TITLE "COMPILATION"
# CFLAGS="-std=c99 -Wall"
# WFLAGS="-Wl,--wrap=system"
# TRACE "gcc $CFLAGS $WFLAGS mycat.c -o mycat &> rnings"
# EVAL $? "compilation" 0 -10

# [ $? -ne 0 ] && MALUS "Compilation" X "errors"
# [ -s warnings ] && MALUS "Compilation" 20 "warnings" &CTRACE "cat warnings"
# [ -x mycat ] && BONUS "Linking" 30

### execution
# TITLE "LAUNCH TEST"
# TRACE "echo \"abcdef\" > mycat.in"
# TRACE "cat mycat.in | ./mycat > mycat.out"
# EVAL $? "return status" 0 -10
# # [ $? -ne 0 ] && MALUS "Return" 10 "bad exit status"
# TRACE "diff -q mycat.in mycat.out"
# EVAL $? "program output" 100 0

# EXIT_GRADE
