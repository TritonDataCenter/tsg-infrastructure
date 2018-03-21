#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

# Dependencies needed by Landscape.
PACKAGES=(
    'python-twisted-core'
    'python-configobj'
    'landscape-common'
)

apt_get_update

for package in "${PACKAGES[@]}"; do
    apt-get --assume-yes install "$package"
done

# Remove the warranty information.
rm -f /etc/legal

rm -f /etc/update-motd.d/10-help-text \
      /etc/update-motd.d/51-cloudguest \
      /etc/update-motd.d/90-updates-available \
      /etc/update-motd.d/91-release-upgrade \
      /etc/update-motd.d/95-hwe-eol \
      /etc/update-motd.d/98-fsck-at-reboot \
      /etc/update-motd.d/98-reboot-required

mkdir -p /etc/landscape
chown root: /etc/landscape
chmod 755 /etc/landscape

cat <<'EOF' > /etc/landscape/client.conf
[sysinfo]
exclude_sysinfo_plugins = Temperature,LandscapeLink
EOF

chown root: /etc/landscape/client.conf
chmod 644 /etc/landscape/client.conf

if [[ -f /etc/init.d/landscape-client ]]; then
    for option in stop disable; do
        systemctl "$option" landscape-client || true
    done
fi

cat <<'EOF' > /etc/update-motd.d/99-footer
#!/bin/sh

# Add extra information when showing message of the day.

[ -f /etc/motd.tail ] && cat /etc/motd.tail 2>/dev/null || true

printf "\n"
exit 0
EOF

chown root: /etc/update-motd.d/99-footer
chmod 755 /etc/update-motd.d/99-footer

rm -f /etc/motd

rm -f /etc/motd.tail
touch /etc/motd.tail

run-parts --lsbsysinit /etc/update-motd.d > /var/run/motd.dynamic

chown root: /var/run/motd.dynamic
chmod 644 /var/run/motd.dynamic
