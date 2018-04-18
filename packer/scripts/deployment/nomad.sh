#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

if getent passwd nomad &>/dev/null; then
    deluser \
        --quiet \
        --system \
        nomad
fi

rm -Rf /etc/nomad \
       /var/log/nomad

rm -f /etc/default/nomad \
      /etc/logrotate.d/nomad
