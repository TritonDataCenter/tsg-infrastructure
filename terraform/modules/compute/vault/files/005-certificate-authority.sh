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

extract_csr() {
    local file="$1"
    [[ $# ]] || shift

    csr=
    set -e
    {
        if [[ ! -t 0 ]]; then
            csr=$(jq -r '.data.csr')
        else
            csr=$(jq -r '.data.csr' "$file")
        fi
    } 2>/dev/null || true
    set +e

    echo "$csr"
}

extract_certificate() {
    local file="$1"
    [[ $# ]] || shift

    certificate=
    set -e
    {
        if [[ ! -t 0 ]]; then
            certificate=$(jq -r '.data.certificate')
        else
            certificate=$(jq -r '.data.certificate' "$file")
        fi
    } 2>/dev/null || true
    set +e

    echo "$certificate"
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly VAULT_HOME='/mnt/vault'
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

curl -sk -L -X POST -H "X-Vault-Token: $ROOT_TOKEN" \
    "http://${VAULT_CNS_URL}:8200/v1/sys/mounts/tsg-root-ca" \
    -d @- <<BODY >/dev/null
{
  "type": "pki",
  "description": "Root Certificate Authority for Triton Service Groups",
  "config": {
    "max_lease_ttl": "87600h"
  }
}
BODY

curl -sk -L -X POST -H "X-Vault-Token: $ROOT_TOKEN" \
    "http://${VAULT_CNS_URL}:8200/v1/sys/mounts/tsg-intermediate-ca" \
    -d @- <<BODY >/dev/null
{
  "type": "pki",
  "description": "Intermediate Certificate Authority for Triton Service Groups",
  "config": {
    "max_lease_ttl": "26280h"
  }
}
BODY

curl -sk -L -X POST -H "X-Vault-Token: $ROOT_TOKEN" \
    "http://${VAULT_CNS_URL}:8200/v1/tsg-root-ca/root/generate/exported" \
    -d @- <<BODY | tee >/dev/null \
        >(openssl enc -aes-256-cbc -e -a -pass file:<(echo "$PSK_KEY") | \
            mput -q "${MANTA_PATH}/root.json") \
        >(extract_certificate > "${VAULT_HOME}/.tls/root-certificate.crt")
{
  "common_name": "Triton Service Groups Root Certificate",
  "ttl": "87600h",
  "key_type": "ec",
  "key_bits": 521,
  "exclude_cn_from_sans": true
}
BODY

curl -sk -L -X POST -H "X-Vault-Token: $ROOT_TOKEN" \
    "http://${VAULT_CNS_URL}:8200/v1/tsg-root-ca/config/urls" \
    -d @- <<BODY
{
  "issuing_certificates": [
    "http://${VAULT_CNS_URL}/v1/tsg-root-ca/ca"
  ],
  "crl_distribution_points": [
    "http://${VAULT_CNS_URL}/v1/tsg-root-ca/crl"
  ]
}
BODY

curl -sk -L -X POST -H "X-Vault-Token: $ROOT_TOKEN" \
    "http://${VAULT_CNS_URL}:8200/v1/tsg-intermediate-ca/intermediate/generate/exported" \
    -d @- <<BODY | extract_csr > "${VAULT_HOME}/.tls/csr.crt"
{
  "common_name": "Triton Service Groups Intermediate Certificate",
  "ttl": "26280h",
  "key_type": "ec",
  "key_bits": 521,
  "exclude_cn_from_sans": true
}
BODY

curl -sk -L -X POST -H "X-Vault-Token: $ROOT_TOKEN" \
    "http://${VAULT_CNS_URL}:8200/v1/tsg-root-ca/root/sign-intermediate" \
    -d @<(jq -n --arg csr "$(<"${VAULT_HOME}/.tls/csr.crt")" \
    "$(cat <<'BODY'
{
  "common_name": "Triton Service Groups Intermediate Certificate",
  "ttl": "8760h",
  "csr": $csr
}
BODY
)") | tee >/dev/null \
    >(openssl enc -aes-256-cbc -e -a -pass file:<(echo "$PSK_KEY") | \
        mput -q "${MANTA_PATH}/intermediate.json") \
    >(extract_certificate > "${VAULT_HOME}/.tls/certificate.crt")

rm -f "${VAULT_HOME}/.tls/csr.crt"

cat \
    "${VAULT_HOME}/.tls/certificate.crt" \
    "${VAULT_HOME}/.tls/root-certificate.crt" | \
        tee "${VAULT_HOME}/.tls/ca-chain.crt" >/dev/null

curl -sk -L -X POST -H "X-Vault-Token: $ROOT_TOKEN" \
    "http://${VAULT_CNS_URL}:8200/v1/tsg-intermediate-ca/intermediate/set-signed" \
    -d @<(jq -n --arg certificate "$(<"${VAULT_HOME}/.tls/ca-chain.crt")" \
    "$(cat <<'BODY'
{
  "certificate": $certificate
}
BODY
)")

rm -f \
    "${VAULT_HOME}/.tls/certificate.crt" \
    "${VAULT_HOME}/.tls/root-certificate.crt" \
    "${VAULT_HOME}/.tls/ca-chain.crt"

curl -sk -L -X POST -H "X-Vault-Token: $ROOT_TOKEN" \
    "http://${VAULT_CNS_URL}:8200/v1/tsg-root-ca/config/urls" \
    -d @- <<BODY
{
  "issuing_certificates": [
    "http://${VAULT_CNS_URL}/v1/tsg-intermediate-ca/ca"
  ],
  "crl_distribution_points": [
    "http://${VAULT_CNS_URL}/v1/tsg-intermediate-ca/crl"
  ]
}
BODY
