#!/bin/bash

# ONLY USE FOR FIRST RUN!!!!
# ...on subsequent starts dimply run "docker start signatumd-node"
docker volume create signatumd-data
docker run -v signatumd-data:/signatum --name=signatumd-node -d -p 33333:33333  -p 127.0.0.1:33334:33334  squbs/signatumd


# run "docker logs signatumd-node" for container output
# run "docker exec -it signatumd-node bash" for interactive shell
