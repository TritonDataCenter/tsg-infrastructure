#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

# A list of common packages to be installed.
PACKAGES=(
    'apt-transport-https'
    'python-software-properties'
    'software-properties-common'
    'chrony'
    'haveged'
    'irqbalance'
    'heirloom-mailx'
    'sysstat'
    'curl'
    'wget'
    'vim'
)

apt_get_update

for package in "${PACKAGES[@]}"; do
    apt-get --assume-yes install "$package"
done

systemctl stop chrony || true

cat <<'EOF' > /etc/chrony/chrony.conf
pool 0.pool.ntp.org iburst offline
pool 1.pool.ntp.org iburst offline
pool 2.pool.ntp.org iburst offline
pool 3.pool.ntp.org iburst offline

keyfile /etc/chrony/chrony.keys

commandkey 1

driftfile /var/lib/chrony/chrony.drift

log tracking measurements statistics
logdir /var/log/chrony

maxupdateskew 100.0
makestep 1.0 3

dumponexit

dumpdir /var/lib/chrony

logchange 0.5

hwclockfile /etc/adjtime

rtcsync
EOF

chown root: /etc/chrony/chrony.conf
chmod 644 /etc/chrony/chrony.conf
chmod 600 /etc/chrony/chrony.keys

sed -i -e \
    's/.*ENABLED="false"/ENABLED="true"/' \
    /etc/default/sysstat

update-alternatives --set editor /usr/bin/vim.basic
