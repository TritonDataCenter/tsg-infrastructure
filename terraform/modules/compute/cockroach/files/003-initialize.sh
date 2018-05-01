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

INIT_ARGUMENTS="--host $HOST"
[[ -n $INSECURE ]] && INIT_ARGUMENTS+=' --insecure'

cockroach init $INIT_ARGUMENTS >/dev/null
