#!/bin/bash

set -e
set -o pipefail

detect_private_address() {
    local status=0
    set +e
    [[ "$1" =~ (10\.|172\.[123]|192\.168\.) ]]
    status=$?
    set -e
    return $status
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

sed -i -e \
    's/DATACENTER_NAME/${data_center_name}/g' \
    /etc/consul/consul.json

sed -i -e \
    's/CONSUL_CNS_URL/${consul_cns_url}/g' \
    /etc/consul/consul.json

IPS=($(hostname -I))

PUBLIC_IP=
for address in "$${IPS[@]}"; do
    if ! detect_private_address "$address"; then
        PUBLIC_IP="$address"
        break
    fi
done

PRIVATE_IP=
for address in "$${IPS[@]}"; do
    if detect_private_address "$address"; then
        PRIVATE_IP="$address"
        break
    fi
done

sed -i -e \
    "s/PUBLIC_IP/$${PUBLIC_IP}/g" \
    /etc/fabio/fabio.properties

sed -i -e \
    "s/PRIVATE_IP/$${PRIVATE_IP}/g" \
    /etc/fabio/fabio.properties

mkdir -p /mnt/consul

chown consul: /mnt/consul
chmod 750 /mnt/consul

for service in consul fabio; do
    for action in enable start; do
        systemctl "$action" "$service"
    done
done
