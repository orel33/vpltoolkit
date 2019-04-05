#!/bin/bash

DOCKER="orel33/mydebian"
DOCKERTIMEOUT=900
DOCKEROPT=""
DOCKEROPT="$DOCKEROPT -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker"
DOCKEROPT="$DOCKEROPT -d --rm -w /tmp"
echo "Starting $DOCKER..."
DOCKERID=$(docker run $DOCKEROPT $DOCKER sleep $DOCKERTIMEOUT)
echo "DOCKERID=$DOCKERID"
docker cp run.sh $DOCKERID:/tmp
docker exec -it $DOCKERID /tmp/run.sh
docker container stop -t 0 $DOCKERID &> /dev/null
docker container rm -f $DOCKERID &> /dev/null
echo "Docker $DOCKER terminated."

# EOF

