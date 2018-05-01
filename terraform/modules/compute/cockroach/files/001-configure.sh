#!/bin/bash

set -e
set -o pipefail

join() {
    local IFS="$1"; shift
    echo "$*"
}

split() {
    local separator="$1"; shift
    echo "${*//${separator}/ }"
}

detect_private_address() {
    local address="$1"
    shift

    local status=0
    set +e
    [[ "$address" =~ (10\.|172\.[123]|192\.168\.) ]]
    status=$?
    set -e

    return $status
}

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

readonly COCKROACH_CLUSTER_FILE='/var/tmp/.cockroach-cluster'

[[ $EUID == 0 ]] || exec sudo -H -E -n "$0" "$@"

if [[ -f $COCKROACH_CLUSTER_FILE ]]; then
    . $COCKROACH_CLUSTER_FILE
else
    echo "File '$COCKROACH_CLUSTER_FILE' could not be found, aborting ..."
    exit 1
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

PRIVATE_IP=$(gomplate -i '{{ sockaddr.GetPrivateIP }}')

if [[ $INSECURE == 'true' ]]; then
    sed -i -e \
        's/.*INSECURE=.*/INSECURE=\"true\"/' \
        /etc/default/cockroach
fi

sed -i -e \
    "s/.*HOST=.*/HOST=\"${PRIVATE_IP}\"/" \
    /etc/default/cockroach

sed -i -e \
    's/.*STORE=.*/STORE=\"\/mnt\/cockroach,size=90%\"/' \
    /etc/default/cockroach

sed -i -e \
    "s/.*ADDITIONAL_ARGS=.*/ADDITIONAL_ARGS=\"${ADDITIONAL_ARGUMENTS}\"/" \
    /etc/default/cockroach

(
    . /etc/default/cockroach

    cat <<EOF | sed -e '/^$/d' > /etc/profile.d/cockroach.sh
export COCKROACH_HOST='${HOST:=127.0.0.1}'
export COCKROACH_PORT='${PORT:=26257}'
$(if [[ -n $INSECURE ]]; then
    echo "export COCKROACH_INSECURE='true'"
fi)
EOF

    chown root: /etc/profile.d/cockroach.sh
    chmod 644 /etc/profile.d/cockroach.sh
)

if which consul &>/dev/null; then
    (
        . /etc/default/cockroach

        : "${PORT:=26257}"
        : "${HTTP_PORT:=8080}"

        cat <<EOF > /etc/consul/conf.d/cockroach.json
{
  "services": [
    {
      "id": "sql",
      "name": "cockroach",
      "tags": [
        "sql"
      ],
      "address": "${HOST}",
      "port": ${PORT},
      "enable_tag_override": false,
      "checks": [
        {
          "id": "sql-check",
          "name": "Cockroach SQL Port Check",
          "tcp": "${HOST}:${PORT}",
          "interval": "10s",
          "timeout": "1s"
        }
      ]
    },
    {
      "id": "http",
      "name": "cockroach",
      "tags": [
        "http"
      ],
      "address": "${HOST}",
      "port": ${HTTP_PORT},
      "enable_tag_override": false,
      "checks": [
        {
          "id": "ui-port-check",
          "name": "Cockroach UI Port Check",
          "tcp": "${HOST}:${HTTP_PORT}",
          "interval": "10s",
          "timeout": "1s"
        },
        {
          "id": "node-health-check",
          "name": "Cockroach Node Health Check",
          "http": "http://${HOST}:${HTTP_PORT}/health",
          "method": "GET",
          "interval": "30s",
          "timeout": "5s"
        },
        {
          "id": "cluster-health-check",
          "name": "Cockroach Cluster Health Check",
          "http": "http://${HOST}:${HTTP_PORT}/_admin/v1/health",
          "method": "GET",
          "interval": "30s",
          "timeout": "5s"
        }
      ]
    }
  ]
}
EOF
    )

    if pgrep -x consul &>/dev/null; then
        kill -HUP $(pgrep -x consul) 2>/dev/null
    fi
fi
