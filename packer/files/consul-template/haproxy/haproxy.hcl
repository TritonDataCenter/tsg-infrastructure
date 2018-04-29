template {
  error_on_missing_key = true

  source      = "/etc/consul-template/template.d/haproxy.cfg.ctmpl"
  destination = "/etc/haproxy/haproxy.cfg"
  perms       = 0644
  backup      = false

  command = "systemctl restart haproxy || true"

  command_timeout = "30s"
}
