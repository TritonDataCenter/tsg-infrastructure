#!/bin/bash

set -e
set -o pipefail

extract_seal_status() {
    local file="$1"
    [[ $# ]] || shift

    sealed=
    set -e
    {
        if [[ ! -t 0 ]]; then
            sealed=$(jq -r '.sealed')
        else
            sealed=$(jq -r '.sealed' "$file")
        fi
    } 2>/dev/null || true
    set +e

    echo "$sealed"
}

extract_unseal_keys() {
    local file="$1"
    [[ $# ]] || shift

    keys=
    set -e
    {
        if [[ ! -t 0 ]]; then
            keys=$(jq -r '.keys_base64 | join("\n")')
        else
            keys=$(jq -r '.keys_base64 | join("\n")' "$file")
        fi
    } 2>/dev/null || true
    set +e

    echo "$keys"
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly MANTA_FILE='/var/tmp/.manta'

[[ $EUID == 0 ]] || exec sudo -H -E -n "$0" "$@"

if [[ -z $PSK_KEY ]]; then
    echo 'The pre-shared key cannot be empty, aborting ...'
    exit 1
fi

if [[ -f $MANTA_FILE ]]; then
    . $MANTA_FILE
else
    echo "File '$MANTA_FILE' could not be found, aborting ..."
    exit 1
fi

trap 'rm -f $MANTA_FILE' EXIT

VAULT_SEALED=$(curl -sk -L \
    'http://127.0.0.1:8200/v1/sys/health' | \
        extract_seal_status)

if [[ $VAULT_SEALED == 'false' ]]; then
    echo 'Vault already unsealed, nothing to do.'
    exit 0
fi

UNSEAL_KEYS=($(
    mget -q "${MANTA_PATH}/credentials.json" | \
        openssl enc -aes-256-cbc -d -a -pass file:<(echo "$PSK_KEY") | \
            extract_unseal_keys
))

for (( i = 0; i < 30; i++ )); do
    KEY="${UNSEAL_KEYS[$(( RANDOM % ${#UNSEAL_KEYS[@]} ))]}"

    VAULT_SEALED=$(curl -sk -L \
        'http://127.0.0.1:8200/v1/sys/health' | \
            extract_seal_status)

    [[ $VAULT_SEALED == 'false' ]] && break

    curl -sk -L -X POST \
        -d "{ \"key\": \"${KEY}\" }" \
        'http://127.0.0.1:8200/v1/sys/unseal' >/dev/null

    sleep 1
done
