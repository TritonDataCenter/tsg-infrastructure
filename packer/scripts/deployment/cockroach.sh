#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

if getent passwd cockroach &>/dev/null; then
    deluser \
        --quiet \
        --system \
        cockroach
fi

rm -Rf /var/log/cockroach \
       /var/lib/cockroach

rm -f /etc/default/cockroach \
      /etc/logrotate.d/cockroach \
      /etc/sysctl.d/99-cockroach.conf

rm -f /lib/systemd/system/cockroach.service

systemctl --system daemon-reload
