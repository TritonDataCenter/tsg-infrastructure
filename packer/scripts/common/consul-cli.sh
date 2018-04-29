#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly CONSUL_CLI_FILES='/var/tmp/consul-cli'

[[ -d $CONSUL_CLI_FILES ]] || mkdir -p "$CONSUL_CLI_FILES"

# The version 0.3.1 is currently the recommended stable version.
if [[ -z $CONSUL_CLI_VERSION ]]; then
    CONSUL_CLI_VERSION='0.3.1'
fi

ARCHIVE_FILE="consul-cli_${CONSUL_CLI_VERSION}_$(detect_os)_$(detect_platform).tar.gz"

wget -O "${CONSUL_CLI_FILES}/${ARCHIVE_FILE}" \
        "https://github.com/mantl/consul-cli/releases/download/v${CONSUL_CLI_VERSION}/${ARCHIVE_FILE}"

tar -zxf "${CONSUL_CLI_FILES}/${ARCHIVE_FILE}" --strip=1 -C \
         "$CONSUL_CLI_FILES"

cp -f "${CONSUL_CLI_FILES}/consul-cli" \
      /usr/local/bin

chown root: /usr/local/bin/consul-cli
chmod 755 /usr/local/bin/consul-cli

rm -Rf "$CONSUL_CLI_FILES"
