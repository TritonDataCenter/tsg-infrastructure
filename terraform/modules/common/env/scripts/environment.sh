#!/bin/bash

set -e
set -u
set -o pipefail

normalize_boolean() {
    local boolean="$1"
    shift

    local status='true'
    [[ "$boolean" =~ (1|yes|true) ]] || status='false'

    echo "$status"
}

fetch_value() {
    local name="$1"
    shift

    local value=
    set +e
    value="${!name:-}"
    set -e

    echo "$value"
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

NAME=
ALLOW_EMPTY_VALUE='false'

if ! test -t 0; then
    eval "$(jq -r '@sh "NAME=\(.name) ALLOW_EMPTY_VALUE=\(.allow_empty_value)"')"
fi

if [[ -z ${!NAME+x} ]]; then
    echo "The environment variable '$NAME' could not be found." >&2
    exit 1
fi

VALUE="$(fetch_value "$NAME")"

if [[ -z $VALUE ]]; then
    if [[ $(normalize_boolean "$ALLOW_EMPTY_VALUE") == 'true' ]]; then
        echo '{ "value": "" }'
        exit 0
    else
        echo "The environment variable '$NAME' is empty." >&2
        exit 1
    fi
fi

jq -c -n --arg value "$VALUE" '{ "value": $value }'
