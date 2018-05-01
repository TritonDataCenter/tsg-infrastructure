#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly CONSUL_TEMPLATE_FILES='/var/tmp/vault/consul-template/haproxy'

cp -f ${CONSUL_TEMPLATE_FILES}/conf.d/*.hcl \
      /etc/consul-template/conf.d

chown root: /etc/consul-template/conf.d/*.hcl
chmod 644 /etc/consul-template/conf.d/*.hcl

cp -f ${CONSUL_TEMPLATE_FILES}/template.d/*.ctmpl \
      /etc/consul-template/template.d

chown root: /etc/consul-template/template.d/*.ctmpl
chmod 644 /etc/consul-template/template.d/*.ctmpl

cp -f ${CONSUL_TEMPLATE_FILES}/plugin.d/* \
      /etc/consul-template/plugin.d

chown root: /etc/consul-template/plugin.d/*
chmod 755 /etc/consul-template/plugin.d/*

rm -Rf "$CONSUL_TEMPLATE_FILES"
