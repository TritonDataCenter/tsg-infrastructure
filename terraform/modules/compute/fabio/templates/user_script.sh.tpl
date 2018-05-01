#!/bin/bash

set -e
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly CA_DIRECTORY='/usr/local/share/ca-certificates'

sed -i -e \
    's/DATACENTER_NAME/${data_center_name}/g' \
    /etc/consul/config.json

sed -i -e \
    's/CONSUL_CNS_URL/${consul_cns_url}/g' \
    /etc/consul/config.json

mkdir -p /mnt/consul \
         /mnt/fabio

chown consul: /mnt/consul
chmod 750 /mnt/consul

chown fabio: /mnt/fabio
chmod 750 /mnt/fabio

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

for action in enable start; do
    systemctl "$action" consul
done
