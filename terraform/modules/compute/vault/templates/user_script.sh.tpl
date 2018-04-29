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

sed -i -e \
    's/CLUSTER_NAME/${cluster_name}/g' \
    /etc/vault/config.hcl

mkdir -p /mnt/consul \
         /mnt/vault

chown consul: /mnt/consul
chmod 750 /mnt/consul

chown vault: /mnt/vault
chmod 750 /mnt/vault

IPS=($(hostname -I))

IP_ADDRESS=
for address in "$${IPS[@]}"; do
    if detect_private_address "$address"; then
        IP_ADDRESS="$address"
        break
    fi
done

sed -i -e \
    "s/PRIVATE_IP/$${IP_ADDRESS}/g" \
    /etc/consul-template/template.d/haproxy.cfg.ctmpl

cat <<EOF > /etc/profile.d/vault.sh
export VAULT_ADDR='http://$${IP_ADDRESS:=127.0.0.1}:8200'
EOF

chown root: /etc/profile.d/vault.sh
chmod 644 /etc/profile.d/vault.sh

for service in consul consul-template; do
    for action in enable start; do
        systemctl "$action" "$service"
    done
done
