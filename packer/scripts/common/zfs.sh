#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

apt_get_update

apt-get install --assume-yes \
    zfsutils-linux \
    zfs-initramfs

cat <<'EOF' > /etc/sysfs.d/zfs.conf
module/zfs/parameters/zfs_vdev_scheduler = noop
module/zfs/parameters/zfs_read_chunk_size = 1310720
module/zfs/parameters/zfs_prefetch_disable = 1
EOF

chown root: /etc/sysfs.d/zfs.conf
chmod 644 /etc/sysfs.d/zfs.conf
