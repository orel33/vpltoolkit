#!/bin/bash


### build
OPT="$*" # --no-cache
echo "OPT=$OPT"
date > build-date.txt # use to enforce the build of certain layers
docker build $OPT -t "orel33/minivpl-ubuntu" . || exit 1

### sync

# https://registry.u-bordeaux.fr/harbor/projects
# docker login registry.u-bordeaux.fr

docker tag "orel33/minivpl-ubuntu" "registry.u-bordeaux.fr/vpltoolkit/orel33/minivpl-ubuntu" || exit 1
docker push registry.u-bordeaux.fr/vpltoolkit/orel33/minivpl-ubuntu

# eof