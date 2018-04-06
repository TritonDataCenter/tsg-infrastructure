#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly NOMAD_FILES='/var/tmp/nomad/client'

if getent passwd nomad &>/dev/null; then
    deluser \
        --quiet \
        --system \
        nomad
fi

chown root:adm /var/log/nomad
chmod 2750 /var/log/nomad

cp -f "${NOMAD_FILES}/config.hcl" \
      /etc/nomad/config.hcl

chown root: /etc/nomad/config.hcl
chmod 644 /etc/nomad/config.hcl

cp -f "${NOMAD_FILES}/nomad.service" \
      /lib/systemd/system/nomad.service

chown root: /lib/systemd/system/nomad.service
chmod 644 /lib/systemd/system/nomad.service

systemctl --system daemon-reload

for action in disable stop; do
    systemctl "$action" nomad || true
done

rm -Rf $NOMAD_FILES
