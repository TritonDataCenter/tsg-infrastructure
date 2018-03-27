#!/bin/bash

set -e

join() {
    local IFS="$1"; shift
    echo "$*"
}

split() {
    local separator="$1"; shift
    echo "${*//${separator}/ }"
}

detect_private_address() {
    local status=0
    set +e
    [[ "$1" =~ (10\.|172\.[123]|192\.168\.) ]]
    status=$?
    set -e
    return $status
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

[[ $EUID == 0 ]] || exec sudo "$0" "$@"

if [[ -f /var/tmp/.cockroach-cluster ]]; then
    . /var/tmp/.cockroach-cluster
fi

NODES=($(split ',' "$NODES" | tr ' ' '\n' | sort))

CLUSTER_NODES=()
for address in "${NODES[@]}"; do
    if detect_private_address "$address"; then
        CLUSTER_NODES+=("$address")
    fi
done

ADDITIONAL_ARGUMENTS+="--cache 25% --max-sql-memory 25% "
ADDITIONAL_ARGUMENTS+="--join '$(join ',' "${CLUSTER_NODES[@]}")'"

IPS=($(hostname -I))

IP_ADDRESS=
for address in "${IPS[@]}"; do
    if detect_private_address "$address"; then
        IP_ADDRESS="$address"
        break
    fi
done

if [[ $INSECURE == 'true' ]]; then
    sed -i -e \
        's/.*INSECURE=.*/INSECURE=\"true\"/' \
        /etc/default/cockroach
fi

sed -i -e \
    "s/.*HOST=.*/HOST=\"${IP_ADDRESS}\"/" \
    /etc/default/cockroach

sed -i -e \
    's/.*STORE=.*/STORE=\"\/srv\/cockroach,size=90%\"/' \
    /etc/default/cockroach

sed -i -e \
    "s/.*ADDITIONAL_ARGS=.*/ADDITIONAL_ARGS=\"${ADDITIONAL_ARGUMENTS}\"/" \
    /etc/default/cockroach

(
    . /etc/default/cockroach

    cat <<EOF | sed -e '/^$/d' > /etc/profile.d/cockroach.sh
export COCKROACH_HOST='${HOST:-127.0.0.1}'
export COCKROACH_PORT='${PORT:-26257}'
$(if [[ -n $INSECURE ]]; then
    echo "export COCKROACH_INSECURE='true'"
fi)
EOF

    chown root: /etc/profile.d/cockroach.sh
    chmod 644 /etc/profile.d/cockroach.sh
)
