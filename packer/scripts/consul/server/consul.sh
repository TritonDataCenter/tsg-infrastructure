#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly CONSUL_FILES='/var/tmp/consul/server'

cp -f "${CONSUL_FILES}/consul.json" \
      /etc/consul/consul.json

chown root: /etc/consul/consul.json
chmod 644 /etc/consul/consul.json

cp -f "${CONSUL_FILES}/consul.service" \
      /lib/systemd/system/consul.service

chown root: /lib/systemd/system/consul.service
chmod 644 /lib/systemd/system/consul.service

systemctl --system daemon-reload

for action in disable stop; do
    systemctl "$action" consul || true
done

rm -Rf $CONSUL_FILES
