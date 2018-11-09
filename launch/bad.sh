#!/bin/bash

# what I dont want (bash control signal messages)
echo "$ ./segfault"
./segfault
echo "return $?"

exit 0

# EOF