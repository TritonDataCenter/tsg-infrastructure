#!/bin/bash

set -e
set -o pipefail

detect_private_address() {
    local address="$1"
    shift

    local status=0
    set +e
    [[ "$address" =~ (10\.|172\.[123]|192\.168\.) ]]
    status=$?
    set -e

    return $status
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly VAULT_HOME='/mnt/vault'

[[ $EUID == 0 ]] || exec sudo -H -E -n "$0" "$@"

if [[ ! -d $VAULT_HOME ]]; then
    echo "Directory '$VAULT_HOME' could not be found, aborting ..."
    exit 1
fi

IPS=($(hostname -I))

PRIVATE_IP=
for address in "${IPS[@]}"; do
    if detect_private_address "$address"; then
        PRIVATE_IP="$address"
        break
    fi
done

sed -i -e \
    "s/PRIVATE_IP/${PRIVATE_IP}/g" \
    /etc/vault/config.hcl

mkdir -p "${VAULT_HOME}/.tls"

chown vault: "${VAULT_HOME}/.tls"
chmod 700 "${VAULT_HOME}/.tls"
