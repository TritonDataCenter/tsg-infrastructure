#!/bin/bash

set -e
set -o pipefail

detect_private_address() {
    local status=0
    set +e
    [[ "$1" =~ (10\.|172\.[123]|192\.168\.) ]]
    status=$?
    set -e
    return $status
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly MANTA_FILE='/var/tmp/.manta'
readonly CERTIFICATE_FILE='/var/tmp/.certificate'

readonly FABIO_HOME='/mnt/fabio'

[[ $EUID == 0 ]] || exec sudo bash "$0" "$@"

FILES=( MANTA_FILE CERTIFICATE_FILE )
for file in "${FILES[@]}"; do
    FILE=${!file}

    if [[ -f $FILE ]]; then
        . $FILE
    else
        echo "File '$FILE' could not be found, aborting ..." >&2
        exit 1
    fi
done

trap "rm -f $MANTA_FILE" EXIT

if [[ ! -d $FABIO_HOME ]]; then
    echo "Directory '$FABIO_HOME' could not be found, aborting ..." >&2
    exit 1
fi

IPS=($(hostname -I))

PUBLIC_IP=
for address in "${IPS[@]}"; do
    if ! detect_private_address "$address"; then
        PUBLIC_IP="$address"
        break
    fi
done

PRIVATE_IP=
for address in "${IPS[@]}"; do
    if detect_private_address "$address"; then
        PRIVATE_IP="$address"
        break
    fi
done

sed -i -e \
    "s/PUBLIC_IP/${PUBLIC_IP}/g" \
    /etc/fabio/fabio.properties

sed -i -e \
    "s/PRIVATE_IP/${PRIVATE_IP}/g" \
    /etc/fabio/fabio.properties

sed -i -e \
    's/.*ListenAddress.*$//g' \
    /etc/ssh/sshd_config

mkdir -p "${FABIO_HOME}/.cs"

chown fabio: "${FABIO_HOME}/.cs"
chmod 700 "${FABIO_HOME}/.cs"

mget -q \
     -o "${FABIO_HOME}/.cs/cert.pem" \
        "${MANTA_PATH}/cert.pem"

mget -q \
     -o "${FABIO_HOME}/.cs/key.pem" \
        "${MANTA_PATH}/key.pem"

chown fabio: "${FABIO_HOME}/.cs/cert.pem" \
             "${FABIO_HOME}/.cs/key.pem"

chmod 700 "${FABIO_HOME}/.cs/cert.pem" \
          "${FABIO_HOME}/.cs/key.pem"
