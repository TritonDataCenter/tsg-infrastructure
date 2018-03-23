#!/bin/bash

set -e

NOMAD_VERSION=0.7.1

apt-get update
apt-get install -y curl unzip

cd /usr/local/bin
wget https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip

unzip *.zip
rm *.zip

mkdir -p /etc/nomad

adduser --disabled-password --gecos "" nomad

mv /tmp/config.hcl /etc/nomad/config.hcl
mv /tmp/nomad.service /etc/systemd/system/nomad.service
