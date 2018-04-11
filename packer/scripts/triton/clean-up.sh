#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

systemctl daemon-reload

for service in syslog syslog-ng rsyslog systemd-journald; do
    systemctl stop "$service" || true
done

for option in '--purge autoremove' 'autoclean' 'clean all'; do
    apt-get --assume-yes $option
done

rm -f /usr/sbin/policy-rc.d

rm -rf /tmp/* /var/tmp/* /usr/tmp/*

rm -rf /var/lib/cloud/data/scripts \
       /var/lib/cloud/scripts/per-instance \
       /var/lib/cloud/data/user-data* \
       /var/lib/cloud/instance \
       /var/lib/cloud/instances/*

rm -rf /var/log/unattended-upgrades

find /var/log /var/cache /var/lib/apt -type f -print0 | \
    xargs -0 rm -f

find /etc /root /home -type f -name 'authorized_keys' -print0 | \
    xargs -0 rm -f

mkdir -p /var/lib/apt/periodic \
         /var/lib/apt/{lists,archives}/partial

chown -R root: /var/lib/apt
chmod -R 755 /var/lib/apt

# Re-create empty directories for system manuals,
# to stop certain package diversions from breaking.
mkdir -p /usr/share/man/man{1..8}

chown -R root: /usr/share/man
chmod -R 755 /usr/share/man

# Newer version of Ubuntu introduce a dedicated
# "_apt" user, which owns the temporary files.
chown _apt: /var/lib/apt/lists/partial

apt-cache gencaches

touch /var/log/{lastlog,wtmp,btmp}

chown root: /var/log/{lastlog,wtmp,btmp}
chmod 644 /var/log/{lastlog,wtmp,btmp}
