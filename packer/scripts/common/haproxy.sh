#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly HAPROXY_FILES='/var/tmp/haproxy'

[[ -d $HAPROXY_FILES ]] || mkdir -p "$HAPROXY_FILES"

PACKAGE='haproxy'
if [[ -n $HAPROXY_VERSION ]]; then
    PACKAGE=$(printf 'haproxy=%s*' "$HAPROXY_VERSION")
fi

cat <<EOF > /etc/apt/sources.list.d/haproxy-1.8.list
deb http://ppa.launchpad.net/vbernat/haproxy-1.8/ubuntu $(detect_ubuntu_release) main
deb-src http://ppa.launchpad.net/vbernat/haproxy-1.8/ubuntu $(detect_ubuntu_release) main
EOF

chown root: /etc/apt/sources.list.d/haproxy-1.8.list
chmod 644 /etc/apt/sources.list.d/haproxy-1.8.list

if [[ -f "${HAPROXY_FILES}/haproxy-1.8.key" ]]; then
    apt-key add "${HAPROXY_FILES}/haproxy-1.8.key"
else
    apt-key adv \
        --keyserver hkp://keyserver.ubuntu.com:80 \
        --recv-keys 1C61B9CD
fi

cat <<EOF > /etc/apt/preferences.d/haproxy
Package: *
Pin: release o=LP-PPA-vbernat-haproxy-1.8
Pin-Priority: 1001
EOF

apt_get_update

apt-get --assume-yes update \
    -o Dir::Etc::SourceList='/etc/apt/sources.list.d/haproxy-1.8.list' \
    -o Dir::Etc::SourceParts='-' -o APT::Get::List-Cleanup='0'

apt-get install --assume-yes "$PACKAGE"

systemctl --system daemon-reload

for action in disable stop; do
    systemctl "$action" haproxy || true
done

rm -Rf "$HAPROXY_FILES"
