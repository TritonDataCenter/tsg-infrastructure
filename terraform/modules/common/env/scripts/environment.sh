#!/bin/bash

set -e
set -u
set -o pipefail

fetch_value() {
    local name="$1"
    local value=''
    set +e
    value="${!name:=''}"
    set -e
    echo "$value"
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

NAME=''
if ! test -t 0; then
    eval "$(jq -r '@sh "NAME=\(.name)"')"
fi

if [[ -z $NAME ]]; then
    echo '{ "value": "" }'
    exit 0
fi

VALUE="$(fetch_value "$NAME")"
jq -c -n --arg value "$VALUE" '{ "value": $value }'
