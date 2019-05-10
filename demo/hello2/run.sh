#!/bin/bash

source env.sh || exit 0
source vpltoolkit/toolkit.sh || exit 0

CHECKVERSION "4.0"
CHECKDOCKER "orel33/mydebian:latest"

GRADE=0
ECHO "hello world!"
EXIT_GRADE

