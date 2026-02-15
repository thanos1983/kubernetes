#!/bin/bash
# Exit if any of the intermediate steps fail
set -e

CERTS=$(kubeadm certs certificate-key)
jq -n --arg certs "$CERTS" '{"certs":$certs}'
