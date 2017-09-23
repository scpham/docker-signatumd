#!/bin/bash
#
# Configure broken host machine to run correctly
#
set -ex

SIGT_IMAGE=${SIGT_IMAGE:-squbs/signatumd:1.1-armhf}

memtotal=$(grep ^MemTotal /proc/meminfo | awk '{print int($2/1024) }')

#
# Only do swap hack if needed
#
if [ $memtotal -lt 2048 -a $(swapon -s | wc -l) -lt 2 ]; then
    fallocate -l 2048M /swap || dd if=/dev/zero of=/swap bs=1M count=2048
    mkswap /swap
    grep -q "^/swap" /etc/fstab || echo "/swap swap swap defaults 0 0" >> /etc/fstab
    swapon -a
fi

free -m

curl -fsSL get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh

puser=$(whoami)
sudo usermod -aG docker $puser

# Always clean-up, but fail successfully
docker kill signatumd-node 2>/dev/null || true
docker rm signatumd-node 2>/dev/null || true
stop docker-signatumd 2>/dev/null || true

# Always pull remote images to avoid caching issues
if [ -z "${SIGT_IMAGE##*/*}" ]; then
    docker pull $SIGT_IMAGE
fi

# Initialize the data container
docker volume create --name=signatumd-data
docker run -v signatumd-data:/signatum --rm $SIGT_IMAGE sigt_init

# Start signatumd via systemd and docker
wget https://raw.githubusercontent.com/squbs/docker-signatumd/master/init/docker-signatumd.service
sudo mv docker-signatumd.service /etc/systemd/system/
sudo systemctl enable docker-signatumd.service


set +ex
echo "Resulting signatum.conf:"
docker run -v signatumd-data:/signatum --rm $SIGT_IMAGE cat /signatum/.signatum/signatum.conf
