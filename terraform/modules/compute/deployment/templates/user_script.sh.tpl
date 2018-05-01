#!/bin/bash

set -e
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly CA_DIRECTORY='/usr/local/share/ca-certificates'

cat <<EOF > /etc/profile.d/consul.sh
export CONSUL_HTTP_ADDR='https://${consul_cns_url}:8500'
EOF

chown root: /etc/profile.d/consul.sh
chmod 644 /etc/profile.d/consul.sh

cat <<EOF > /etc/profile.d/vault.sh
export VAULT_ADDR='https://${vault_cns_url}:8200'
EOF

chown root: /etc/profile.d/vault.sh
chmod 644 /etc/profile.d/vault.sh

cat <<EOF > /etc/profile.d/cockroach.sh
export COCKROACH_HOST='${cockroach_cns_url}'
export COCKROACH_INSECURE='${cockroach_insecure}'
EOF

chown root: /etc/profile.d/cockroach.sh
chmod 644 /etc/profile.d/cockroach.sh

cat <<EOF > /etc/profile.d/nomad.sh
export NOMAD_ADDR='https://${nomad_cns_url}:4646'
EOF

chown root: /etc/profile.d/nomad.sh
chmod 644 /etc/profile.d/nomad.sh

mkdir -p "$${CA_DIRECTORY}/tsg"

chown root: "$${CA_DIRECTORY}/tsg"
chmod 755 "$${CA_DIRECTORY}/tsg"

PKI=( 'tsg-root-ca' 'tsg-intermediate-ca' )
for pki in "$${PKI[@]}"; do
    (curl -sk -L "http://${vault_cns_url}/v1/$${pki}/ca/pem"; echo) | \
        tee "$${CA_DIRECTORY}/tsg/$${pki}.crt" >/dev/null

    chown root: "$${CA_DIRECTORY}/tsg/$${pki}.crt"
    chown 644 "$${CA_DIRECTORY}/tsg/$${pki}.crt"
done

update-ca-certificates --fresh >/dev/null
