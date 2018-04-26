#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

apt_get_update

apt-get install --assume-yes make

npm install \
    --no-progress \
    --unsafe-perm \
    --global \
    manta

cp -f \
    "$(npm prefix -g)/lib/node_modules/manta/share/manta.completion" \
    /etc/bash_completion.d/manta

chown root: /etc/bash_completion.d/manta
chmod 644 /etc/bash_completion.d/manta
