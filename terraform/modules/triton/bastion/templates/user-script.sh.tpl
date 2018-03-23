#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

hostnamectl --static set-hostname "${hostname}"

for service in syslog syslog-ng rsyslog systemd-journald; do
    systemctl restart "$service" 2>/dev/null || true
done
