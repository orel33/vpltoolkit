#!/bin/bash
docker build -t "orel33/mydebian:latest" . && docker push "orel33/mydebian:latest"
docker build -t "orel33/mydebian:user" -f Dockerfile.user . && docker push "orel33/mydebian:user"
