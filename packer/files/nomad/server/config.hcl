bind_addr = "{{ GetPrivateIP }}"

datacenter = "DATACENTER_NAME"

data_dir = "/mnt/nomad"

log_level     = "INFO"
enable_syslog = false
enable_debug  = false

leave_on_terminate = true

server {
  enabled = true

  encrypt          = "SxUuq3DshhG2UO9F7VviYg=="
  bootstrap_expect = 3

  rejoin_after_leave = true
}

consul {
  address = "127.0.0.1:8500"

  auto_advertise       = true
  server_service_name  = "nomad"
  server_auto_join     = true
  checks_use_advertise = true
}

disable_anonymous_signature = true
disable_update_check        = true
