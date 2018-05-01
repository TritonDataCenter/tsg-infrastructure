#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly CONSUL_FILES='/var/tmp/vault/consul/server'

cp -f "${CONSUL_FILES}/config.json" \
      /etc/consul/config.json

chown root: /etc/consul/config.json
chmod 644 /etc/consul/config.json

rm -Rf "$CONSUL_FILES"
