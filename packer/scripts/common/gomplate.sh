#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly GOMPLATE_FILES='/var/tmp/gomplate'

[[ -d $GOMPLATE_FILES ]] || mkdir -p "$GOMPLATE_FILES"

apt_get_update

if [[ -z $GOMPLATE_VERSION ]]; then
    GOMPLATE_VERSION='2.5.0'
fi

BINARY_FILE="gomplate_$(detect_os)-$(detect_platform)"

wget -O "${GOMPLATE_FILES}/gomplate" \
    "https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/${BINARY_FILE}"

cp -f "${GOMPLATE_FILES}/gomplate" \
      /usr/local/bin/gomplate

chown root: /usr/local/bin/gomplate
chmod 755 /usr/local/bin/gomplate

rm -Rf "$GOMPLATE_FILES"
