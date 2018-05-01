#!/bin/bash

set -e
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

[[ $EUID == 0 ]] || exec sudo -H -E -n "$0" "$@"

PRIVATE_IP=$(gomplate -i '{{ sockaddr.GetPrivateIP }}')

cat <<EOF > /etc/profile.d/consul.sh
export CONSUL_HTTP_ADDR='http://${PRIVATE_IP}:8500'
EOF

chown root: /etc/profile.d/consul.sh
chmod 644 /etc/profile.d/consul.sh
