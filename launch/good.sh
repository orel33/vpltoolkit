#!/bin/bash

# silent mode
echo "$ ./launch -s \"./segfault\""
./launch -s "./segfault"
echo "return $?"

# regular mode
echo "$ ./launch \"./segfault\""
./launch "./segfault"
echo "return $?"

exit 0

# EOF