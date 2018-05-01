#!/bin/bash

set -e
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly VAULT_HOME='/mnt/vault'

[[ $EUID == 0 ]] || exec sudo -H -E -n "$0" "$@"

if [[ ! -d $VAULT_HOME ]]; then
    echo "Directory '$VAULT_HOME' could not be found, aborting ..."
    exit 1
fi

PRIVATE_IP=$(gomplate -i '{{ sockaddr.GetPrivateIP }}')

sed -i -e \
    "s/PRIVATE_IP/${PRIVATE_IP}/g" \
    /etc/vault/config.hcl

sed -i -e \
    "s/PRIVATE_IP/${PRIVATE_IP}/g" \
    /etc/consul-template/template.d/haproxy.cfg.ctmpl

cat <<EOF > /etc/profile.d/vault.sh
export VAULT_ADDR='https://${PRIVATE_IP}:8200'
EOF

chown root: /etc/profile.d/vault.sh
chmod 644 /etc/profile.d/vault.sh

mkdir -p "${VAULT_HOME}/.tls"

chown vault: "${VAULT_HOME}/.tls"
chmod 700 "${VAULT_HOME}/.tls"
