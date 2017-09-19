Signatumd for Docker
===================

[![Docker Stars](https://img.shields.io/docker/stars/squbs/signatumd.svg)](https://hub.docker.com/r/squbs/signatumd/)
[![Docker Pulls](https://img.shields.io/docker/pulls/squbs/signatumd.svg)](https://hub.docker.com/r/squbs/signatumd/)
[![Build Status](https://travis-ci.org/squbs/docker-signatumd.svg?branch=master)](https://travis-ci.org/squbs/docker-signatumd/)
[![ImageLayers](https://images.microbadger.com/badges/image/squbs/signatumd.svg)](https://microbadger.com/#/images/squbs/signatumd)

Docker image that runs the Signatum signatumd node in a container for easy deployment.


Requirements
------------

* Physical machine, cloud instance, or VPS that supports Docker (i.e. [Vultr](http://bit.ly/1HngXg0), [Digital Ocean](http://bit.ly/18AykdD), KVM or XEN based VMs) running Ubuntu 14.04 or later (*not OpenVZ containers!*)
* At least 5 GB to store the block chain files (and always growing!)
* At least 1 GB RAM + 2 GB swap file


Really Fast Quick Start
-----------------------

One liner for Ubuntu Trusty/Xenial/Zesty machines with JSON-RPC enabled on localhost and adds upstart init script:

    curl https://raw.githubusercontent.com/squbs/docker-signatumd/master/bootstrap-host.sh


Quick Start
-----------

1. Create a `signatumd-data` volume to persist the signatumd blockchain data, should exit immediately.  The `signatumd-data` container will store the blockchain when the node container is recreated (software upgrade, reboot, etc):

        docker volume create --name=signatumd-data
        docker run -v signatumd-data:/signatum --name=signatumd-node -d \
            -p 33333:33333 \
            -p 127.0.0.1:33334:33334 \
            squbs/signatumd

2. Verify that the container is running and signatumd node is downloading the blockchain

        $ docker ps
        CONTAINER ID        IMAGE                         COMMAND             CREATED             STATUS              PORTS                                              NAMES
        d0e1076b2dca        squbs/signatumd:latest     "sigt_oneshot"       2 seconds ago       Up 1 seconds        127.0.0.1:33333->33333/tcp, 0.0.0.0:33334->33334/tcp   signatumd-node

3. You can then access the daemon's output thanks to the [docker logs command]( https://docs.docker.com/reference/commandline/cli/#logs)

        docker logs -f signatumd-node

4. Install optional init scripts for upstart and systemd are in the `init` directory.

5. Run the following to open a bash shell within a running container to interact with signatumd:

	docker exec -it signatumd-node bash


Documentation
-------------

* Additional documentation in the [docs folder](docs).
