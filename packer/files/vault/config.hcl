disable_mlock = false

default_lease_ttl = "24h"
max_lease_ttl     = "168h""

ui = true

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = true
}

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}
