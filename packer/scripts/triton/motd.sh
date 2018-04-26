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

cat <<'EOF' > /etc/update-motd.d/10-triton
#!/bin/sh

[ -f /etc/os-release-triton ] || exit 0

# Add information about this particular Triton instance e.g., version, etc.
. /etc/os-release-triton

# Calculate the level of indentation.
_indent() { echo "(${#1} + 75) / 2" | bc; }

readonly HEADER="$BUILD_NAME (${BUILDER_TYPE})"
readonly VERSION="Version: ${VERSION}"

printf "\n%*s\n" "$(_indent "$HEADER")" "$HEADER"
cat <<'EOS' | base64 -d
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICBfX19fXyBfX19fXyBfX19fXwogICAgICAgICAg
ICAgICAgICAgICAgICAgICAgfF8gICBffCAgIF9ffCAgIF9ffAogICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICB8IHwgfF9fICAgfCAgfCAgfAogICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICB8X3wgfF9fX19ffF9fX19ffAo=
EOS
printf "%*s\n%*s\n" \
  "$(_indent "$BUILD_DATE")" "$BUILD_DATE" \
  "$(_indent "${VERSION}")" "$VERSION"

exit 0
EOF

chown root: /etc/update-motd.d/10-triton
chmod 755 /etc/update-motd.d/10-triton
