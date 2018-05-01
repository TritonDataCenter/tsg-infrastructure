#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly CONSUL_TEMPLATE_FILES='/var/tmp/consul-template/common'

[[ -d $CONSUL_TEMPLATE_FILES ]] || mkdir -p "$CONSUL_TEMPLATE_FILES"

apt_get_update

if ! dpkg -s unzip &>/dev/null; then
    apt-get --assume-yes install \
        unzip
fi

if [[ -z $CONSUL_TEMPLATE_VERSION ]]; then
    CONSUL_TEMPLATE_VERSION='0.19.4'
fi

ARCHIVE_FILE="consul-template_${CONSUL_TEMPLATE_VERSION}_$(detect_os)_$(detect_platform).zip"

wget -O "${CONSUL_TEMPLATE_FILES}/${ARCHIVE_FILE}" \
        "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/${ARCHIVE_FILE}"

unzip -q "${CONSUL_TEMPLATE_FILES}/${ARCHIVE_FILE}" \
      -d "$CONSUL_TEMPLATE_FILES"

cp -f "${CONSUL_TEMPLATE_FILES}/consul-template" \
      /usr/local/bin/consul-template

chown root: /usr/local/bin/consul-template
chmod 755 /usr/local/bin/consul-template

mkdir -p /etc/consul-template \
         /etc/consul-template/conf.d \
         /etc/consul-template/template.d \
         /etc/consul-template/plugin.d \
         /var/log/consul-template

chown root: /etc/consul-template \
            /etc/consul-template/conf.d \
            /etc/consul-template/template.d \
            /etc/consul-template/plugin.d

chmod 755 /etc/consul-template \
          /etc/consul-template/conf.d \
          /etc/consul-template/template.d \
          /etc/consul-template/plugin.d

chown root:adm /var/log/consul-template
chmod 2750 /var/log/consul-template

cp -f "${CONSUL_TEMPLATE_FILES}/config.hcl" \
      /etc/consul-template

chown root: /etc/consul-template/config.hcl
chmod 644 /etc/consul-template/config.hcl

cp -f "${CONSUL_TEMPLATE_FILES}/consul-template.default" \
      /etc/default/consul-template

chown root: /etc/default/consul-template
chmod 644 /etc/default/consul-template

cp -f "${CONSUL_TEMPLATE_FILES}/consul-template.logrotate" \
      /etc/logrotate.d/consul-template

chown root: /etc/logrotate.d/consul-template
chmod 644 /etc/logrotate.d/consul-template

cp -f "${CONSUL_TEMPLATE_FILES}/consul-template.service" \
      /lib/systemd/system/consul-template.service

chown root: /lib/systemd/system/consul-template.service
chmod 644 /lib/systemd/system/consul-template.service

systemctl --system daemon-reload

for action in disable stop; do
    systemctl "$action" consul-template || true
done
rm -Rf "$CONSUL_TEMPLATE_FILES"
