#!/bin/bash
set -e

# For Jammy 22.04 LTS
# Versions info https://haproxy.debian.net/#distribution=Ubuntu&release=jammy&version=3.0
HAPROXY_VERSION="3.0"

sudo DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends software-properties-common
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:vbernat/haproxy-$HAPROXY_VERSION -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y haproxy=$HAPROXY_VERSION.\*

sudo mv /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg
sudo systemctl enable haproxy.service
sudo systemctl restart haproxy.service
