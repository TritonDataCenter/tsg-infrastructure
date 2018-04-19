#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly LEVANT_FILES='/var/tmp/levant/common'

[[ -d $LEVANT_FILES ]] || mkdir -p "$LEVANT_FILES"

# The version 0.1.0 is currently the recommended stable version.
if [[ -z $LEVANT_VERSION ]]; then
    LEVANT_VERSION='0.1.0'
fi

apt_get_update

apt-get --assume-yes install unzip

wget -O "${LEVANT_FILES}/levant" \
    "https://github.com/jrasell/levant/releases/download/${LEVANT_VERSION}/linux-$(detect_platform)-levant"

cp -f "${LEVANT_FILES}/levant" \
      /usr/local/bin/levant

chown root: /usr/local/bin/levant
chmod 755 /usr/local/bin/levant

rm -Rf $LEVANT_FILES
