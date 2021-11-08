#!/bin/bash

set -x

# docker build -t "orel33/myubuntu:latest" .
# docker push "orel33/myubuntu:latest"

docker login registry.gitlab.com # login:orel33

docker build -t registry.gitlab.com/orel33/test .

docker push registry.gitlab.com/orel33/test


