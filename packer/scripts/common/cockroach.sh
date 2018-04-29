#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly COCKROACH_FILES='/var/tmp/cockroach'

[[ -d $COCKROACH_FILES ]] || mkdir -p "$COCKROACH_FILES"

apt_get_update

apt-get --assume-yes install ntpdate

# The version 1.1.7 is currently the recommended stable version.
if [[ -z $COCKROACH_VERSION ]]; then
    COCKROACH_VERSION='1.1.7'
fi

ARCHIVE_FILE="cockroach-v${COCKROACH_VERSION}.$(detect_os)-$(detect_platform).tgz"

wget -O "${COCKROACH_FILES}/${ARCHIVE_FILE}" \
    "https://binaries.cockroachdb.com/${ARCHIVE_FILE}"

tar -zxf "${COCKROACH_FILES}/${ARCHIVE_FILE}" --strip=1 -C \
         "$COCKROACH_FILES"

cp -f "${COCKROACH_FILES}/cockroach" \
      /usr/local/bin

chown root: /usr/local/bin/cockroach
chmod 755 /usr/local/bin/cockroach

adduser \
    --quiet \
    --system \
    --group \
    --home /nonexistent \
    --no-create-home \
    --disabled-login \
    cockroach

mkdir -p /var/log/cockroach \
         /var/lib/cockroach

chown cockroach:adm /var/log/cockroach
chmod 2750 /var/log/cockroach

chown cockroach: /var/lib/cockroach
chmod 750 /var/lib/cockroach

cp -f "${COCKROACH_FILES}/cockroach.default" \
      /etc/default/cockroach

chown root: /etc/default/cockroach
chmod 644 /etc/default/cockroach

cp -f "${COCKROACH_FILES}/cockroach.service" \
      /lib/systemd/system/cockroach.service

chown root: /lib/systemd/system/cockroach.service
chmod 644 /lib/systemd/system/cockroach.service

cp -f "${COCKROACH_FILES}/cockroach.logrotate" \
      /etc/logrotate.d/cockroach

chown root: /etc/logrotate.d/cockroach
chmod 644 /etc/logrotate.d/cockroach

systemctl --system daemon-reload

for action in disable stop; do
    systemctl "$action" cockroach || true
done

cat <<'EOF' > /etc/sysctl.d/99-cockroach.conf
fs.file-max = 1048576
EOF

chown root: /etc/sysctl.d/99-cockroach.conf
chmod 644 /etc/sysctl.d/99-cockroach.conf

cockroach gen autocomplete \
    --out=/etc/bash_completion.d/cockroach

chown root: /etc/bash_completion.d/cockroach
chmod 644 /etc/bash_completion.d/cockroach

rm -Rf "$COCKROACH_FILES"
