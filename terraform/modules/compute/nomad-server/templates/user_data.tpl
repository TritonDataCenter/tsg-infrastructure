#!/bin/bash

sed -i -e "s/TRITON_DC/${dc}/g" /etc/nomad/config.hcl
sed -i -e "s/TRITON_URL/${dc}/g" /etc/consul.d/client/client.json

sed -i -e "s/TRITON_CONSUL_CNS_URL/${cns_url}/g" /etc/consul.d/client/client.json

mkdir /mnt/nomad
chown nomad:nomad /mnt/nomad

mkdir -p /mnt/consul
chown consul:consul /mnt/consul

systemctl enable nomad
systemctl enable consul
systemctl start nomad
systemctl start consul
