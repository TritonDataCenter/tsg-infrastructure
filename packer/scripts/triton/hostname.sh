#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

cat <<EOF > /etc/hosts
127.0.0.1 localhost.localdomain localhost loopback
EOF

chown root: /etc/hosts
chmod 644 /etc/hosts

hostnamectl --static set-deployment 'triton'
hostnamectl --static set-icon-name 'network-server'
hostnamectl --static set-location "$PACKER_BUILDER_TYPE"
hostnamectl --static set-chassis 'server'

for service in syslog syslog-ng rsyslog systemd-journald; do
    systemctl restart "$service" || true
done
