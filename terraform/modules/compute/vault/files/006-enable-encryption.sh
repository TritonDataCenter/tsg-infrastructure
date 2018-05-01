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

extract_root_token() {
    local file="$1"
    [[ $# ]] || shift

    token=
    set -e
    {
        if [[ ! -t 0 ]]; then
            token=$(jq -r '.root_token')
        else
            token=$(jq -r '.root_token' "$file")
        fi
    } 2>/dev/null || true
    set +e

    echo "$token"
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly VAULT_HOME='/mnt/vault'
readonly MANTA_FILE='/var/tmp/.manta'
readonly VAULT_FILE='/var/tmp/.vault'

readonly CA_DIRECTORY='/usr/local/share/ca-certificates'

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

if [[ ! -d $VAULT_HOME ]]; then
    echo "Directory '$VAULT_HOME' could not be found, aborting ..."
    exit 1
fi

VAULT_SEALED=$(curl -sk -L \
    'http://127.0.0.1:8200/v1/sys/health' | \
        extract_seal_status)

if [[ $VAULT_SEALED == 'true' ]]; then
    echo 'Vault is sealed, aborting ...'
    exit 1
fi

ROOT_TOKEN=$(
    mget -q "${MANTA_PATH}/credentials.json" | \
        openssl enc -aes-256-cbc -d -a -pass file:<(echo "$PSK_KEY") | \
            extract_root_token
)

mkdir -p "${CA_DIRECTORY}/tsg"
chown root: "${CA_DIRECTORY}/tsg"
chmod 755 "${CA_DIRECTORY}/tsg"

PKI=( 'tsg-root-ca' 'tsg-intermediate-ca' )
for pki in "${PKI[@]}"; do
    (curl -sk -L "http://127.0.0.1:8200/v1/${pki}/ca/pem"; echo) | \
        tee "${CA_DIRECTORY}/tsg/${pki}.crt" >/dev/null

    chown root: "${CA_DIRECTORY}/tsg/${pki}.crt"
    chown 644 "${CA_DIRECTORY}/tsg/${pki}.crt"
done

update-ca-certificates --fresh >/dev/null

curl -sk -L -X POST -H "X-Vault-Token: $ROOT_TOKEN" \
    "http://${VAULT_CNS_URL}:8200/v1/tsg-intermediate-ca/roles/vault" \
    -d @- <<BODY
{
  "max_ttl": "8760h",
  "key_type": "ec",
  "key_bits": 384,
  "generate_lease": true,
  "allow_ip_sans": true,
  "allow_any_name": true
}
BODY

curl -sk -L -X PUT \
    'http://127.0.0.1:8500/v1/kv/vault/core/tls/configuration' \
    -d @<(jq -c . <<BODY
{
  "vault_cns_url": "${VAULT_CNS_URL}",
  "key_file": "${VAULT_HOME}/.tls/key.pem",
  "cert_file": "${VAULT_HOME}/.tls/cert.pem",
  "ca_file": "${VAULT_HOME}/.tls/ca.pem"
}
BODY
) >/dev/null

export VAULT_TOKEN="$ROOT_TOKEN"

consul-template \
    -config /etc/consul-template/config.hcl \
    -config /etc/consul-template/conf.d \
    -template "/etc/consul-template/template.d/cert.pem.ctmpl:${VAULT_HOME}/.tls/cert.pem" \
    -once &>/dev/null

chown vault: ${VAULT_HOME}/.tls/*.pem
chmod 600 ${VAULT_HOME}/.tls/*.pem

curl -sk -L -X PUT \
    'http://127.0.0.1:8500/v1/kv/vault/core/tls/active' \
    -d @- <<BODY >/dev/null
true
BODY
