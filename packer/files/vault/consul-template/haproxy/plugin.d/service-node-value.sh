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

FILTER='.Address'
if (( $# > 1 )); then
    if  [[ -n "$1" ]]; then
        FILTER="$1"
        shift
    fi
fi

DELIMETER=','
if (( $# > 1 )); then
    if [[ -n "$1" ]]; then
        DELIMETER="$1"
        shift
    fi
fi

jq --arg filter "$FILTER" --arg delimiter "$DELIMETER" -r \
   '[.[] | to_entries[] | select(.key == ($filter | split(".") | last)).value] | join($delimiter)' \
   -- <<<"$@"
