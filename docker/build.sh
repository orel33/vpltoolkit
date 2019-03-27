#!/bin/bash
docker build -t "orel33/mydebian:latest" . && docker push "orel33/mydebian:latest"
