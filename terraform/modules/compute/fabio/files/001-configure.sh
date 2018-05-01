#!/bin/bash

set -e
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly MANTA_FILE='/var/tmp/.manta'
readonly FABIO_HOME='/mnt/fabio'

[[ $EUID == 0 ]] || exec sudo -H -E -n "$0" "$@"

if [[ -f $MANTA_FILE ]]; then
    . $MANTA_FILE
else
    echo "File '$MANTA_FILE' could not be found, aborting ..."
    exit 1
fi

trap 'rm -f $MANTA_FILE' EXIT

if [[ ! -d $FABIO_HOME ]]; then
    echo "Directory '$FABIO_HOME' could not be found, aborting ..."
    exit 1
fi

PUBLIC_IP=$(gomplate -i '{{ sockaddr.GetPublicIP }}')

sed -i -e \
    "s/PUBLIC_IP/${PUBLIC_IP}/g" \
    /etc/fabio/fabio.properties

PRIVATE_IP=$(gomplate -i '{{ sockaddr.GetPrivateIP }}')

sed -i -e \
    "s/PRIVATE_IP/${PRIVATE_IP}/g" \
    /etc/fabio/fabio.properties

mkdir -p "${FABIO_HOME}/.tls"

chown fabio: "${FABIO_HOME}/.tls"
chmod 700 "${FABIO_HOME}/.tls"

mget -q \
     -o "${FABIO_HOME}/.tls/cert.pem" \
        "${MANTA_PATH}/cert.pem"

mget -q \
     -o "${FABIO_HOME}/.tls/key.pem" \
        "${MANTA_PATH}/key.pem"

chown fabio: "${FABIO_HOME}/.tls/cert.pem" \
             "${FABIO_HOME}/.tls/key.pem"

chmod 700 "${FABIO_HOME}/.tls/cert.pem" \
          "${FABIO_HOME}/.tls/key.pem"
