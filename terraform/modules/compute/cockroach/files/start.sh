#!/bin/bash

set -e
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly COCKROACH_CLUSTER_FILE='/var/tmp/.cockroach-cluster'

[[ $EUID == 0 ]] || exec sudo bash "$0" "$@"

if [[ -f $COCKROACH_CLUSTER_FILE ]]; then
    . $COCKROACH_CLUSTER_FILE
else
    echo "File '$COCKROACH_CLUSTER_FILE' could not be found, aborting ..." >&2
    exit 1
fi

. /etc/default/cockroach

systemctl --system daemon-reload

if which ntpdate &>/dev/null; then
    systemctl stop ntp || true

    for retries in {1..5}; do
        ntpdate -4 -b pool.ntp.org &>/dev/null && break
    done
fi

systemctl start ntp

for action in enable start; do
    systemctl "$action" cockroach 2> /dev/null
done

STATUS=0
for retries in {1..30}; do
    set +e
    curl -s --connect-timeout 5 "http://${HOST}:8080/health" &>/dev/null
    STATUS=$?
    set -e

    [[ $STATUS == 0 ]] && break

    sleep 1
done

IPS=($(hostname -I))

FOUND_LEADER=
for address in "${IPS[@]}"; do
    if [[ $LEADER == "$address" ]]; then
        FOUND_LEADER=true
        break
    fi
done

if [[ -n $FOUND_LEADER ]]; then
    INIT_ARGUMENTS="--host $HOST"
    [[ -n $INSECURE ]] && INIT_ARGUMENTS+=' --insecure'

    cockroach init $INIT_ARGUMENTS
fi
