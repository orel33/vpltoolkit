#!/bin/bash

source env.sh || exit 0
source vpltoolkit/toolkit.sh || exit 0

CHECKVERSION "4.0"

####################################################

# function error()
# {
#     local lineno=$1
#     local cmd=$2
#     PRINTKO "ERROR: $cmd (line $lineno)"
#     exit 0
# }

# trap "error ${LINENO} \"${BASH_COMMAND}\"" ERR
 
####################################################

gcc -std=c99 segfault.c -o segfault
[ $? -ne 0 ] && echo "Error: compilation segfault.c" && exit 0

####################################################

TITLE "TEST TOOLKIT API"

### TEST ECHO ###
ECHO "hello world!"
[ $? -eq 0 ] && PRINTOK "ECHO MSG: OK"

### TEST CAT ###
rm -f output
for N in $(seq 10) ; do
    echo "$N: hello world!" >> output
done
CAT output
[ $? -eq 0 ] && PRINTOK "CAT FILE: OK"

CAT output 3 0
[ $? -eq 0 ] && PRINTOK "CAT FILE HEAD 0: OK"

CAT output 0 3
[ $? -eq 0 ] && PRINTOK "CAT FILE 0 TAIL: OK"

CAT output 3 3
[ $? -eq 0 ] && PRINTOK "CAT FILE HEAD TAIL: OK"

### TEST TRACE ###

EXEC "timeout 1 ./segfault"
[ $? -eq 139 ] && PRINTOK "EXEC SEGFAULT: OK"

INFO "Done."

# EOF
