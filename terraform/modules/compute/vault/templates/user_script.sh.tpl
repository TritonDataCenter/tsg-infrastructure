#!/bin/bash

set -e
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

sed -i -e \
    's/DATACENTER_NAME/${data_center_name}/g' \
    /etc/consul/config.json

sed -i -e \
    's/CONSUL_CNS_URL/${consul_cns_url}/g' \
    /etc/consul/config.json

sed -i -e \
    's/CLUSTER_NAME/${cluster_name}/g' \
    /etc/vault/config.hcl

mkdir -p /mnt/consul \
         /mnt/vault

chown consul: /mnt/consul
chmod 750 /mnt/consul

chown vault: /mnt/vault
chmod 750 /mnt/vault

for service in consul consul-template; do
    for action in enable start; do
        systemctl "$action" "$service"
    done
done
