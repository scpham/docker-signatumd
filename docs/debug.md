# Debugging

## Things to Check

* RAM utilization -- signatumd is very hungry and typically needs in excess of 1GB.  A swap file might be necessary.
* Disk utilization -- The signatum blockchain will continue growing and growing and growing.  Then it will grow some more.  At the time of writing, 40GB+ is necessary.

## Viewing signatumd Logs

    docker logs signatumd-node


## Running Bash in Docker Container

*Note:* This container will be run in the same way as the signatumd node, but will not connect to already running containers or processes.

    docker run -v signatumd-data:/signatum --rm -it squbs/signatumd bash -l

You can also attach bash into running container to debug running signatumd

    docker exec -it signatumd-node bash -l


