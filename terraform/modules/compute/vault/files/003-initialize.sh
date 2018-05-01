#!/bin/bash

set -e
set -o pipefail

extract_initialization_status() {
    local file="$1"
    [[ $# ]] || shift

    initialized=
    set -e
    {
        if [[ ! -t 0 ]]; then
            initialized=$(jq -r '.initialized')
        else
            initialized=$(jq -r '.initialized' "$file")
        fi
    } 2>/dev/null || true
    set +e

    echo "$initialized"
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly MANTA_FILE='/var/tmp/.manta'
readonly VAULT_FILE='/var/tmp/.vault'

[[ $EUID == 0 ]] || exec sudo -H -E -n "$0" "$@"

if [[ -z $PSK_KEY ]]; then
    echo 'The pre-shared key cannot be empty, aborting ...'
    exit 1
fi

FILES=( 'MANTA_FILE' 'VAULT_FILE' )
for file in "${FILES[@]}"; do
    FILE=${!file}

    if [[ -f $FILE ]]; then
        . $FILE
    else
        echo "File '$FILE' could not be found, aborting ..."
        exit 1
    fi
done

trap 'rm -f $MANTA_FILE $VAULT_FILE' EXIT

STATUS=0
for (( i = 0; i < 30; i++ )); do
    set +e
    curl -sk -L --connect-timeout 5 "http://127.0.0.1:8200/v1/sys/health" &>/dev/null
    STATUS=$?
    set -e

    [[ $STATUS == 0 ]] && break

    sleep 1
done

VAULT_INITIALIZED=$(curl -sk -L \
    'http://127.0.0.1:8200/v1/sys/init' | \
        extract_initialization_status)

if [[ $VAULT_INITIALIZED == 'true' ]]; then
    echo 'Vault cluster already initialized, nothing to do.'
    exit 0
fi

curl -sk -L -X POST \
    -d "{ \"secret_shares\": $SECRET_SHARES, \"secret_threshold\": $SECRET_THRESHOLD }" \
    'http://127.0.0.1:8200/v1/sys/init' | \
        openssl enc -aes-256-cbc -e -a -pass file:<(echo "$PSK_KEY") | \
            mput -q "${MANTA_PATH}/credentials.json"
