#!/bin/bash

set -e

CONSUL_VERSION=1.0.6

apt-get update
apt-get install -y curl unzip

cd /usr/local/bin
wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

unzip *.zip
rm *.zip

mkdir -p /etc/consul.d/server

adduser --disabled-password --gecos "" consul

mv /tmp/server.json /etc/consul.d/server/config.json
mv /tmp/consul-server.service /etc/systemd/system/consul-server.service
