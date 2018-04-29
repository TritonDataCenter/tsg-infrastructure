#!/bin/bash

set -e
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

[[ $EUID == 0 ]] || exec sudo -H -E -n "$0" "$@"

for action in enable start; do
    systemctl "$action" vault 2> /dev/null
done
