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

sed -i -e \
    's/DATACENTER_NAME/${data_center_name}/g' \
    /etc/nomad/config.hcl

sed -i -e \
    's/NOMAD_CNS_URL/${nomad_cns_url}/g' \
    /etc/nomad/config.hcl

sed -i -e \
    's/NOMAD_CLIENT_ROLE/${nomad_client_role}/g' \
    /etc/nomad/config.hcl

mkdir -p /mnt/consul \
         /mnt/nomad

chown consul: /mnt/consul
chmod 750 /mnt/consul

chown root: /mnt/nomad
chmod 750 /mnt/nomad

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

for service in consul nomad; do
    for action in enable start; do
        systemctl "$action" "$service"
    done
done
