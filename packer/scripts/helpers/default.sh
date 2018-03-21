#!/usr/bin/bash

join() {
    local IFS="$1"; shift
    echo "$*"
}

apt_get_update() {
    # Refresh packages index only when needed.
    local update_stamp='/var/lib/apt/periodic/update-success-stamp'
    if [[ ! -f $update_stamp ]] || \
       (( $(date +%s) - $(date -r $update_stamp +%s) > 900 )); then
        apt-get --assume-yes update 1>/dev/null
    fi
}

detect_platform() {
    case "$(uname -m)" in
        x86|i?86)
            echo i386;
        ;;
        x86_64|amd64)
            echo amd64;
        ;;
    esac
}

clean_apt_policy() {
    rm -f /usr/sbin/policy-rc.d
}

umask 022

export LC_ALL=C LANGUAGE=C LANG=C

export DEBIAN_FRONTEND='noninteractive'
export DEBCONF_NONINTERACTIVE_SEEN='true'

trap clean_apt_policy EXIT

cat <<'EOF' > /usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF

