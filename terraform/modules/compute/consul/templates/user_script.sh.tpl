#!/bin/bash

set -e
set -o pipefail

detect_private_address() {
    local address="$1"
    shift

    local status=0
    set +e
    [[ "$address" =~ (10\.|172\.[123]|192\.168\.) ]]
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

mkdir -p /mnt/consul

chown consul: /mnt/consul
chmod 750 /mnt/consul

IPS=($(hostname -I))

IP_ADDRESS=
for address in "$${IPS[@]}"; do
    if detect_private_address "$address"; then
        IP_ADDRESS="$address"
        break
    fi
done

cat <<EOF > /etc/profile.d/consul.sh
export CONSUL_HTTP_ADDR='http://$${IP_ADDRESS:=127.0.0.1}:8500'
EOF

chown root: /etc/profile.d/consul.sh
chmod 644 /etc/profile.d/consul.sh

for action in enable start; do
    systemctl "$action" consul
done
