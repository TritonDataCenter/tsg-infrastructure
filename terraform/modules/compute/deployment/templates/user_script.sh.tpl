#!/bin/bash

set -e
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

cat <<EOF > /etc/profile.d/consul.sh
export CONSUL_HTTP_ADDR='http://${consul_cns_url}:8500'
EOF

chown root: /etc/profile.d/consul.sh
chmod 644 /etc/profile.d/consul.sh

cat <<EOF > /etc/profile.d/vault.sh
export VAULT_ADDR='http://${vault_cns_url}:8200'
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
export NOMAD_ADDR='http://${nomad_cns_url}:4646'
EOF

chown root: /etc/profile.d/nomad.sh
chmod 644 /etc/profile.d/nomad.sh
