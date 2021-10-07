#!/bin/bash
OPT="$*" # --no-cache
echo "OPT=$OPT"
date > build-date.txt # use to enforce the build of certain layers
docker build $OPT -t "orel33/minivpl-ubuntu" . && docker push "orel33/minivpl-ubuntu"

