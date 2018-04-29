#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

if getent passwd consul &>/dev/null; then
    deluser \
        --quiet \
        --system \
        consul
fi

rm -Rf /etc/consul \
       /var/log/consul

rm -f /etc/default/consul \
      /etc/logrotate.d/consul
