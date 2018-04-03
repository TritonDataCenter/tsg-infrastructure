#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

if [[ -n $PACKER_BUILD_TIMESTAMP ]]; then
    BUILD_TIMESTAMP="$PACKER_BUILD_TIMESTAMP"
else
    BUILD_TIMESTAMP=$(TZ=UTC date +%s)
fi

readonly BUILD_DATE="$(date -d "@${BUILD_TIMESTAMP}")"

cat <<EOF > /etc/os-release-triton
BUILD_NAME="${PACKER_BUILD_NAME:-"UNKNOWN"}"
BUILD_NUMBER=${BUILD_NUMBER:-0}
BUILD_TIMESTAMP=$BUILD_TIMESTAMP
BUILD_DATE="${BUILD_DATE}"
BUILDER_TYPE="${PACKER_BUILDER_TYPE:-"UNKNOWN"}"
VERSION="${PACKER_BUILD_VERSION:-"DEVELOPMENT"}"
EOF

chown root: /etc/os-release-triton
chmod 644 /etc/os-release-triton
