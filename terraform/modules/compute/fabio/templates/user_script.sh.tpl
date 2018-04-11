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

mkdir -p /mnt/consul \
         /mnt/fabio

chown consul: /mnt/consul
chmod 750 /mnt/consul

chown fabio: /mnt/fabio
chmod 750 /mnt/fabio

for action in enable start; do
    systemctl "$action" consul
done
