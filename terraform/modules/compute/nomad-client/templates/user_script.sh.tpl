#!/bin/bash

set -e
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

sed -i -e \
    's/DATACENTER_NAME/${data_center_name}/g' \
    /etc/consul/consul.json

sed -i -e \
    's/CONSUL_CNS_URL/${consul_cns_url}/g' \
    /etc/consul/consul.json

sed -i -e \
    's/DATACENTER_NAME/${data_center_name}/g' \
    /etc/nomad/config.hcl

sed -i -e \
    's/NOMAD_CNS_URL/${nomad_cns_url}/g' \
    /etc/nomad/config.hcl

mkdir -p /mnt/consul \
         /mnt/nomad

chown consul: /mnt/consul
chmod 750 /mnt/consul

chown nomad: /mnt/nomad
chmod 750 /mnt/nomad

for service in consul nomad; do
    for action in enable start; do
        systemctl "$action" "$service"
    done
done
