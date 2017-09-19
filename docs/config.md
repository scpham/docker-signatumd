signatumd config tuning
======================

You can use environment variables to customize config ([see docker run environment options](https://docs.docker.com/engine/reference/run/#/env-environment-variables)):

        docker run -v signatumd-data:/signatum --name=signatumd-node -d \
            -p 33334:33334 \
            -p 127.0.0.1:33333:33333 \
            -e DISABLEWALLET=1 \
            -e PRINTTOCONSOLE=1 \
            -e RPCUSER=mysecretrpcuser \
            -e RPCPASSWORD=mysecretrpcpassword \
            squbs/signatumd

Or you can use your very own config file like that:

        docker run -v signatumd-data:/signatum --name=signatumd-node -d \
            -p 33334:33334 \
            -p 127.0.0.1:33333:33333 \
            -v /etc/mysignatum.conf:/signatum/.signatum/signatum.conf \
            squbs/signatumd
