bind_addr = "{{ GetPrivateIP }}"

datacenter = "DATACENTER_NAME"

data_dir = "/mnt/nomad"

log_level     = "INFO"
enable_syslog = false
enable_debug  = false

leave_on_terminate = true

client {
  enabled = true

  servers = [
    "NOMAD_CNS_URL",
  ]

  options = {
    "user.blacklist"         = "root,ubuntu"
    "user.checked_drivers"   = "exec,raw_exec"
    "driver.raw_exec.enable" = "1"
  }

  reserved {
    reserved_ports = "22,25,80,443,8080,8500-8600"
  }
}

consul {
  address = "127.0.0.1:8500"

  auto_advertise       = true
  checks_use_advertise = true
  client_service_name  = "nomad-client"
  client_auto_join     = true
}

disable_anonymous_signature = true
disable_update_check        = true
