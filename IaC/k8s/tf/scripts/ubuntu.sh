#!/bin/bash
set -e

sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && sudo DEBIAN_FRONTEND=noninteractive apt-get autoclean -y && sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
