#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly CONSUL_FILES='/var/tmp/consul/client'

cp -f "${CONSUL_FILES}/config.json" \
      /etc/consul/config.json

chown root: /etc/consul/config.json
chmod 644 /etc/consul/config.json

cp -f "${CONSUL_FILES}/consul.service" \
      /lib/systemd/system/consul.service

chown root: /lib/systemd/system/consul.service
chmod 644 /lib/systemd/system/consul.service

systemctl --system daemon-reload

for action in disable stop; do
    systemctl "$action" consul || true
done

rm -Rf "$CONSUL_FILES"
