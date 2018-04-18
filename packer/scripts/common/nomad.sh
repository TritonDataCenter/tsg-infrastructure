#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly NOMAD_FILES='/var/tmp/nomad/common'

[[ -d $NOMAD_FILES ]] || mkdir -p "$NOMAD_FILES"

# The version 0.7.1 is currently the recommended stable version.
if [[ -z $NOMAD_VERSION ]]; then
    NOMAD_VERSION='0.7.1'
fi

apt_get_update

apt-get --assume-yes install unzip

ARCHIVE_FILE="nomad_${NOMAD_VERSION}_$(detect_os)_$(detect_platform).zip"

wget -O "${NOMAD_FILES}/${ARCHIVE_FILE}" \
        "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/${ARCHIVE_FILE}"

unzip -q "${NOMAD_FILES}/${ARCHIVE_FILE}" \
      -d "$NOMAD_FILES"

cp -f "${NOMAD_FILES}/nomad" \
      /usr/local/bin/nomad

chown root: /usr/local/bin/nomad
chmod 755 /usr/local/bin/nomad

adduser \
    --quiet \
    --system \
    --group \
    --home /nonexistent \
    --no-create-home \
    --disabled-login \
    nomad

mkdir -p /etc/nomad \
         /etc/nomad/conf.d \
         /var/log/nomad

chown root: /etc/nomad \
            /etc/nomad/conf.d

chmod 755 /etc/nomad \
          /etc/nomad/conf.d

chown nomad:adm /var/log/nomad
chmod 2750 /var/log/nomad

cp -f "${NOMAD_FILES}/nomad.default" \
      /etc/default/nomad

chown root: /etc/default/nomad
chmod 644 /etc/default/nomad

cp -f "${NOMAD_FILES}/nomad.logrotate" \
      /etc/logrotate.d/nomad

chown root: /etc/logrotate.d/nomad
chmod 644 /etc/logrotate.d/nomad

cat <<'EOF' > /etc/bash_completion.d/nomad
complete -C /usr/local/bin/nomad nomad
EOF

chown root: /etc/bash_completion.d/nomad
chmod 644 /etc/bash_completion.d/nomad

rm -Rf $NOMAD_FILES
