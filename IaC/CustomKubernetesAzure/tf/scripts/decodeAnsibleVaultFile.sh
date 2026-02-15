#!/bin/bash
# Exit if any of the intermediate steps fail
set -e

eval "$(jq -r '@sh "VAULTENCRYPTEDFILE=\(.vaultencryptedfile)"')"

CERTS=$(ansible-vault view $VAULTENCRYPTEDFILE)
jq -n --arg certs "$CERTS" '{"certs":$certs}'
