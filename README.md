Signatumd for Docker
===================

[![Docker Stars](https://img.shields.io/docker/stars/squbs/signatumd.svg)](https://hub.docker.com/r/squbs/signatumd/)
[![Docker Pulls](https://img.shields.io/docker/pulls/squbs/signatumd.svg)](https://hub.docker.com/r/squbs/signatumd/)
[![ImageLayers](https://images.microbadger.com/badges/image/squbs/signatumd.svg)](https://microbadger.com/#/images/squbs/signatumd)

Docker image that runs the Signatum signatumd node in a container for easy deployment.


Requirements
------------

* Physical machine, cloud instance, or VPS that supports Docker (i.e. [Digital Ocean](https://goo.gl/eWziH7), KVM or XEN based VMs) running Ubuntu 16.04 or later (*not OpenVZ containers!*)
* At least 5 GB to store the block chain files (chain will grow continously)
* At least 1 GB RAM + 2 GB swap file
* Run `sudo usermod -aG docker <user>` and then logout/login or reboot, if you're a new Docker user
* Encrypted wallets will need to be unlocked for staking (see below)


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
        docker run -v signatumd-data:/signatum --name=signatumd -d \
            -p 33333:33333 \
            -p 33334:33334 \
            squbs/signatumd

2. Verify that the container is running and `signatumd` daemon is downloading the blockchain:

        $ docker ps
        CONTAINER ID        IMAGE                         COMMAND             CREATED             STATUS              PORTS                                              NAMES
        ee825ac17747     squbs/signatumd:latest     "sigt_oneshot"       2 seconds ago       Up 1 seconds        127.0.0.1:33333->33333/tcp, 0.0.0.0:33334->33334/tcp   signatumd

3. You can then access the daemon's output thanks to the [docker logs command]( https://docs.docker.com/reference/commandline/cli/#logs)

        $ docker logs -f signatumd

4. Install optional init scripts for upstart and systemd located in the `init` directory.


General Commands
----------------

1. Open a bash shell within the running container and issue commands to the daemon:

        $ docker exec -it signatumd bash
        $ signatumd getinfo
        $ signatumd getstakinginfo

2. Copy file (e.g. signatum.conf) in and out of the container: 
        
        # Copy to your local dir:
        $ docker cp signatumd:/signatum/.signatum/signatum.conf .
        
        # Copy back to the container: 
        $ docker signatum.conf signatumd:/signatum/.signatum/signatum.conf 

        # Stop/start the container
        $ docker stop signatumd
        $ docker start signatumd

3. Backup wallet (two approaches): 

        # Approach 1 
        # This will create a human readable file dump (depending on encryption status etc):

        (a) Dump wallet:
            $ docker exec -it  signatumd signatumd dumpwallet backup_wallet.dat
        
        (b) Copy to local dir: 
            $ docker cp signatumd:/signatum/backup_wallet.dat .


        # Approach 2
        # This will create a binary file:

        (a) Copy dat file to local dir: 
            $ docker cp signatumd:/signatum/.signatum/wallet.dat backup_wallet.dat

4. Check `signatumd` log file using system `tail -f` command:

        $ docker ps

        # Note the 'COINTAINER ID' for signatumd
        CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                                                       NAMES
        ee825ac17747        squbs/signatumd:1.0   "docker-entrypoint..."   21 seconds ago      Up 21 seconds       26174/tcp, 26178/tcp, 33334/tcp, 0.0.0.0:33333->33333/tcp   signatumd`

        # Run inspect command on container id
        $ docker inspect --format='{{.LogPath}}' ee825ac17747

        # Docker will output location and filename of the container log file:  
        $ /var/lib/docker/containers/ee825ac17747f2abaf627600860697e1213249ab83bb0cf136684dd4a4b7f55d/ee825ac17747f2abaf627600860697e1213249ab83bb0cf136684dd4a4b7f55d-json.log
        
        $ tail -f ee825ac17747f2abaf627600860697e1213249ab83bb0cf136684dd4a4b7f55d-json.log

5. Modify `signatum.conf` and/or `wallet.dat` files without `docker cp`:

        $ docker volume inspect signatumd-data
       
        # output: 
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

        # The 'Mountpoint' directory is the system location of all your user files that reside within the container.
        # 'cd' into this directory - use sudo if you have permission issues - and then copy your conf 
        # and wallet files over existing files that may exist in the `.signatum/` folder
        # WARNING: make sure to stop the `signatumd` process before changing config or wallet files

6. Simple json-rpc call to signatumd from another machine (or host):

        # username and password can be found in the `signatum.conf` file
        # daemon-host-ip can be localhost/0.0.0.0/127.0.0.1 or a lan/wan ip address
        $ curl -s --user '<username>:<password>' --data-binary '{"jsonrpc": "2.0","method": "getinfo", "params": [] }' -H 'content-type: application/json-rpc;' http://<daemon-host-ip>:33334

   If you have `jq` installed, you can do some pretty json printing:
        
        $ curl -s --user '<username>:<password>' --data-binary '{"jsonrpc": "2.0","method": "getinfo", "params": [] }' -H 'content-type: application/json-rpc;' http://127.0.0.1:33334 | jq '.'

   Or `python -m json.tool`:

        $ curl -s --user '<username>:<password>' --data-binary '{"jsonrpc": "2.0","method": "getinfo", "params": [] }' -H 'content-type: application/json-rpc;' http://127.0.0.1:33334 | python -m json.tool

7. For POS phase, you will need to unlock your wallet - if it is encrypted - and set a timeout:

        $ docker exec -it signatumd bash

        # daemon command line: `walletpassphrase <passphrase> <timeout> [stakingonly]`
        # set timeout to t+1 year in seconds: 31557600
        $ signatumd walletpassphrase 'sigt1234' 31557600 true

        # command will return immediately, if successful.
        # wait for 5 minutes and then check staking status:
        $ signatumd getstakinginfo


Documentation
-------------

* Additional documentation in the [docs folder](docs).


Donations
---------

Are not needed.  But if you feel so obliged:

        SIGT: BBsMH69Lv7z4qyncPQBzeSyZjmxhmiGHrg
        BTC:  1PEL8acsjGpJPsfyNn6nCiqGNgDGZPP51N
