#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly FABIO_FILES='/var/tmp/fabio'

[[ -d $FABIO_FILES ]] || mkdir -p "$FABIO_FILES"

# The version 1.5.8 is currently the recommended stable version.
if [[ -z $FABIO_VERSION ]]; then
    FABIO_VERSION='1.5.8'
fi

DOWNLOAD_URL=$(wget -q -O- https://api.github.com/repos/fabiolb/fabio/releases/latest 2>/dev/null | \
    grep -Eo '"browser_download_url":.*fabio-'${FABIO_VERSION}'-.*-'$(detect_os)'_'$(detect_platform)'"' | \
        awk '{ print $2 }' | tr -d '"')

wget -O "${FABIO_FILES}/fabio" \
        "$DOWNLOAD_URL"

cp -f "${FABIO_FILES}/fabio" \
      /usr/local/bin/fabio

chown root: /usr/local/bin/fabio
chmod 755 /usr/local/bin/fabio

setcap 'cap_net_bind_service=+ep' \
       /usr/local/bin/fabio

adduser \
    --quiet \
    --system \
    --group \
    --home /nonexistent \
    --no-create-home \
    --disabled-login \
    fabio

mkdir -p /etc/fabio \
         /var/log/fabio

chown root: /etc/fabio
chmod 755 /etc/fabio

chown fabio:adm /var/log/fabio
chmod 2750 /var/log/fabio

cp -f "${FABIO_FILES}/fabio.properties" \
      /etc/fabio/fabio.properties

chown root: /etc/fabio/fabio.properties
chmod 644 /etc/fabio/fabio.properties

cp -f "${FABIO_FILES}/fabio.default" \
      /etc/default/fabio

chown root: /etc/default/fabio
chmod 644 /etc/default/fabio

cp -f "${FABIO_FILES}/fabio.service" \
      /lib/systemd/system/fabio.service

chown root: /lib/systemd/system/fabio.service
chmod 644 /lib/systemd/system/fabio.service

cp -f "${FABIO_FILES}/fabio.logrotate" \
      /etc/logrotate.d/fabio

chown root: /etc/logrotate.d/fabio
chmod 644 /etc/logrotate.d/fabio

systemctl --system daemon-reload

for action in disable stop; do
    systemctl "$action" fabio || true
done

cat <<'EOF' > /etc/sysctl.d/99-fabio.conf
fs.file-max = 1048576
EOF

chown root: /etc/sysctl.d/99-fabio.conf
chmod 644 /etc/sysctl.d/99-fabio.conf

rm -Rf $FABIO_FILES
