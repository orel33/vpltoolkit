#!/bin/bash
OPT="$*" # --no-cache
echo "OPT=$OPT"
docker build $OPT -t "orel33/minivpl-ubuntu" . && docker push "orel33/minivpl-ubuntu"

