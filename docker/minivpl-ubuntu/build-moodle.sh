#!/bin/bash
date > build-date.txt # use to enforce the build of certain layers
docker build -t "orel33/minivpl-ubuntu" . && docker --config="/root/.docker.orel/" push "orel33/minivpl-ubuntu"
