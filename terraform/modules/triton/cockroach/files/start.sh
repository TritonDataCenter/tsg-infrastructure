#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

[[ $EUID == 0 ]] || exec sudo "$0" "$@"

if [[ -f /var/tmp/.cockroach-cluster ]]; then
    . /var/tmp/.cockroach-cluster
fi

. /etc/default/cockroach

systemctl --system daemon-reload

if which ntpdate &>/dev/null; then
    systemctl stop ntp || true
    ntpdate -4 -b pool.ntp.org >/dev/null
fi

systemctl start ntp

for action in enable start; do
    systemctl "$action" cockroach 2> /dev/null
done

RETRIES=0
while [[ -z $OUTPUT ]] && (( RETRIES < 30 )); do
    set +e
    OUTPUT=$(curl --connect-timeout 5 "http://${HOST}:8080/health" 2>/dev/null)
    set -e

    RETRIES=$(( RETRIES + 1 ))

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
