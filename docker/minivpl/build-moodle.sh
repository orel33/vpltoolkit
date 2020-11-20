#!/bin/bash

docker build -t "orel33/minivpl:latest" . && docker --config="/root/.docker.orel/" push "orel33/minivpl:latest"
