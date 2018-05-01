#!/bin/bash

set -e
set -u
set -o pipefail

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

if ! which 'jq' &>/dev/null; then
    echo "Unable to find the 'jq' binary, aborting..." >&2
    exit 1
fi

if [[ $# == 0 ]]; then
    echo 'Unable to parse data, aborting...' >&2
    exit 1
fi

FILE="$1"
shift

APPEND=
if (( $# > 1 )); then
    if [[ "$1" == 'true' ]]; then
        APPEND='-a'
        shift
    fi
fi

MODE=
if (( $# > 1 )); then
    if [[ $1 =~ ^[0-9]+$ ]]; then
        MODE="$1"
        shift
    fi
fi

tee $APPEND "$FILE" -- <<<"$@"

if [[ -n $MODE ]]; then
    chmod "$MODE" "$FILE" 1>/dev/null
fi
