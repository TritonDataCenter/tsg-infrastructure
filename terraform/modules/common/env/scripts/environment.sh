#!/bin/bash

set -e
set -u
set -o pipefail

fetch_environment() {
    local environment="$1"
    local value=''

    set +e
    value="${!environment-}"
    set -e

    echo "$value"
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

ENVIRONMENT=${ENVIRONMENT-}

if ! test -t 0; then
    eval "$(jq -r '@sh "ENVIRONMENT=\(.environment)"')"
fi

ENVIRONMENT="$(fetch_environment "$ENVIRONMENT")"

jq -c -n --arg environment "$ENVIRONMENT" '{ "environment": $environment }'
