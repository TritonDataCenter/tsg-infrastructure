#!/bin/bash

set -e
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly COCKROACH_CLUSTER_FILE='/var/tmp/.cockroach-cluster'

[[ $EUID == 0 ]] || exec sudo -H -E -n "$0" "$@"

if [[ -f $COCKROACH_CLUSTER_FILE ]]; then
    . $COCKROACH_CLUSTER_FILE
else
    echo "File '$COCKROACH_CLUSTER_FILE' could not be found, aborting ..."
    exit 1
fi

. /etc/default/cockroach

systemctl --system daemon-reload

if which chronyc &>/dev/null; then
    systemctl stop chrony || true

    for (( i = 0; i < 5; i++ )); do
        chronyd -4 -q 'pool pool.ntp.org iburst' &>/dev/null && break
    done

    systemctl start chrony
else
    if which ntpdate &>/dev/null; then
        systemctl stop ntp || true

        for (( i = 0; i < 5; i++ )); do
            ntpdate -4 -b pool.ntp.org &>/dev/null && break
        done
    fi

    systemctl start ntp
fi

for action in enable start; do
    systemctl "$action" cockroach 2> /dev/null
done

STATUS=0
for (( i = 0; i < 30; i++ )); do
    set +e
    curl -sk -L --connect-timeout 5 "http://${HOST}:8080/health" &>/dev/null
    STATUS=$?
    set -e

    [[ $STATUS == 0 ]] && break

    sleep 1
done
