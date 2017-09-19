#!/bin/bash

docker ps -a | grep "signatumd" | awk '{print $3}' | xargs docker rmi
docker images | grep "signatumd" | awk '{print $1}' | xargs docker rm
docker volume rm signatumd-data
