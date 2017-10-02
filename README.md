Signatumd for Docker
===================

[![Docker Stars](https://img.shields.io/docker/stars/squbs/signatumd.svg)](https://hub.docker.com/r/squbs/signatumd/)
[![Docker Pulls](https://img.shields.io/docker/pulls/squbs/signatumd.svg)](https://hub.docker.com/r/squbs/signatumd/)
[![ImageLayers](https://images.microbadger.com/badges/image/squbs/signatumd.svg)](https://microbadger.com/#/images/squbs/signatumd)

Docker image that runs the Signatum signatumd node in a container for easy deployment.


Requirements
------------

* Physical machine, cloud instance, or VPS that supports Docker (i.e. [Digital Ocean](https://goo.gl/eWziH7), KVM or XEN based VMs) running Ubuntu 16.04 or later (*not OpenVZ containers!*)
* At least 5 GB to store the block chain files (the chain will contine to grow)
* At least 1 GB RAM + 2 GB swap file
* Note: if you have Docker permission issues run: `usermod -aG docker <user>` and then logout/logback-in or reboot


Really Fast Quick Start
-----------------------

One liner for Ubuntu Xenial/Zesty machines with JSON-RPC enabled on localhost and adds systemd service:

    curl https://raw.githubusercontent.com/squbs/docker-signatumd/master/bootstrap-host.sh | sh

For Raspberry Pi 2/3:

    curl https://raw.githubusercontent.com/squbs/docker-signatumd/master/bootstrap-host-armhf.sh |  sh


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
        ee825ac17747     squbs/signatumd:latest     "sigt_oneshot"       2 seconds ago       Up 1 seconds        127.0.0.1:33333->33333/tcp, 0.0.0.0:33334->33334/tcp   signatumd-node

3. You can then access the daemon's output thanks to the [docker logs command]( https://docs.docker.com/reference/commandline/cli/#logs)

        docker logs -f signatumd-node

4. Install optional init scripts for upstart and systemd are in the `init` directory.


General Commands
----------------

1. Run the following to open a bash shell within a running container to interact with signatumd:

        docker exec -it signatumd-node bash

2. To copy config file in and out of the container: 

        Copy to your local dir: docker cp signatumd-node:/signatum/.signatum/signatum.conf .
        Copy back to the container: docker signatum.conf signatumd-node:/signatum/.signatum/signatum.conf 

        And then stop/start the container


3. To backup wallet you can either simply dump wallet or copy 'wallet.dat' out of the container: 

        Approach 1: This will create a human readable file dump (depending on encryption status etc):

        (a) Dump wallet: docker exec -it  signatumd-node signatumd dumpwallet backup_wallet.dat
        (b) Copy to local dir: docker cp signatumd-node:/signatum/backup_wallet.dat .

        OR

        Approach 2: This will create a binary file:

        (a) Copy dat file to local dir: docker cp signatumd-node:/signatum/.signatum/wallet.dat backup_wallet.dat
	

4. To 'tail -f' container log file directly:

        $ docker ps

        # note the 'COINTAINER ID' for signatumd
        
        CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                                                       NAMES
        ee825ac17747        squbs/signatumd:1.0   "docker-entrypoint..."   21 seconds ago      Up 21 seconds       26174/tcp, 26178/tcp, 33334/tcp, 0.0.0.0:33333->33333/tcp   signatumd`

	    $ docker inspect --format='{{.LogPath}}' ee825ac1774

        # the output lists the actual the container log file:  
	    # e.g.
        # /var/lib/docker/containers/ee825ac17747f2abaf627600860697e1213249ab83bb0cf136684dd4a4b7f55d/ee825ac17747f2abaf627600860697e1213249ab83bb0cf136684dd4a4b7f55d-json.log
        

5. To copy a signatum.conf file directly and/or wallet.dat:

        $ docker volume inspect signatumd-data
        
        
        [
            {
                "CreatedAt": "2017-09-26T16:07:53Z",
                "Driver": "local",
                "Labels": {},
                "Mountpoint": "/var/lib/docker/volumes/signatumd-data/_data",
               	"Name": "signatumd-data",
                "Options": {},
                "Scope": "local"
            }
        ]

        # note the 'Mountpoint' directory.  This is the system location of all your files within the container.
        # you can CD into this directory - use sudo if you have permission issues - and then copy your conf and wallet files over existing files in the `.signatum/` folder
        # WARNING: make sure you stop the docker signatumd process before changing config and wallet files


Documentation
-------------

* Additional documentation in the [docs folder](docs).


Donations
---------

Are not needed.  But if you feel obliged:

SIGT: BBsMH69Lv7z4qyncPQBzeSyZjmxhmiGHrg

BTC: 1PEL8acsjGpJPsfyNn6nCiqGNgDGZPP51N


