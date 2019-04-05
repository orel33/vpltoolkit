#!/bin/bash

DOCKEROPT=""
DOCKEROPT="$DOCKEROPT -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker"
docker run -it --rm  $DOCKEROPT orel33/mydebian bash

# EOF

