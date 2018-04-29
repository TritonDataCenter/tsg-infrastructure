#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

if getent passwd vault &>/dev/null; then
    deluser \
        --quiet \
        --system \
        vault
fi

rm -Rf /etc/vault \
       /var/log/vault

rm -f /etc/default/vault \
      /etc/logrotate.d/vault

rm -f /lib/systemd/system/vault.service

systemctl --system daemon-reload
