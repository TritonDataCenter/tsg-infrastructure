#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

[[ $EUID == 0 ]] || exec sudo "$0" "$@"

readonly ATTACHED_VOLUME='/dev/vdb'

sed -i -e \
  "/^$(echo $ATTACHED_VOLUME | sed -e 's/\//\\\//g')/d" \
  /etc/fstab

grep -E "$ATTACHED_VOLUME" /proc/mounts | \
    awk '{ print length, $2 }' | \
        sort -gr | cut -d' ' -f2- | xargs umount -f || true

for directory in /mnt /srv; do
    if [[ -d $directory ]]; then
        umount -f "$directory" &>/dev/null || true
        rm -Rf ${directory}/*
    else
        mkdir -p "$directory"
    fi

    chown root: "$directory"
    chmod 755 "$directory"
done

wipefs -a$(wipefs -f &>/dev/null && echo 'f') $ATTACHED_VOLUME

mkfs.xfs -q -L '/srv' -f $ATTACHED_VOLUME >/dev/null

cat <<EOS | sed -e 's/\s\+/\t/g' | tee -a /etc/fstab >/dev/null
$ATTACHED_VOLUME /srv xfs defaults,noatime,nodiratime,nobarrier,nofail,comment=cloudconfig 0 2
EOS

cat <<'EOS' | sed -e 's/\s\+/\t/g' | tee -a /etc/fstab >/dev/null
/srv/cockroach /var/lib/cockroach none bind 0 2
EOS

sed -i -e \
    '/^#/!s/\s\+/\t/g' \
    /etc/fstab

chown root: /etc/fstab
chmod 644 /etc/fstab

mount /srv
xfs_info $ATTACHED_VOLUME

sync
sync

echo 3 > /proc/sys/vm/drop_caches

mkdir -p /srv/cockroach

chown cockroach: /srv/cockroach
chmod 750 /srv/cockroach

mount -a

