#!/bin/bash
# Exit if any of the intermediate steps fail
set -e

eval "$(jq -r '@sh "KUBECONFIG=\(.kubeconfig)"')"

TOKEN=$(kubeadm token create --print-join-command --kubeconfig $KUBECONFIG)
jq -n --arg token "$TOKEN" '{"token":$token}'
