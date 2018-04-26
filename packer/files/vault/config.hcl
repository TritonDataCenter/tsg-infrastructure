cluster_name = "CLUSTER_NAME"

disable_mlock = false

default_lease_ttl = "24h"
max_lease_ttl     = "720h"

ui = true

listener "tcp" {
  address         = "PRIVATE_IP:8200"
  cluster_address = "PRIVATE_IP:8201"
  tls_disable = true
}

storage "consul" {
  address = "127.0.0.1:8500"
  scheme  = "http"
  path    = "vault/"
}
