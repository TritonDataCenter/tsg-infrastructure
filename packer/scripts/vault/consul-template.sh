#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly CONSUL_TEMPLATE_FILES='/var/tmp/consul-template/haproxy'

[[ -d $CONSUL_TEMPLATE_FILES ]] || mkdir -p "$CONSUL_TEMPLATE_FILES"

cp -f "${CONSUL_TEMPLATE_FILES}/haproxy.hcl" \
      /etc/consul-template/conf.d/haproxy.hcl

chown root: /etc/consul-template/conf.d/haproxy.hcl
chmod 755 /etc/consul-template/conf.d/haproxy.hcl

cp -f "${CONSUL_TEMPLATE_FILES}/haproxy.cfg.ctmpl" \
      /etc/consul-template/template.d/haproxy.cfg.ctmpl

chown root: /etc/consul-template/template.d/haproxy.cfg.ctmpl
chmod 755 /etc/consul-template/template.d/haproxy.cfg.ctmpl

rm -Rf "$CONSUL_TEMPLATE_FILES"
