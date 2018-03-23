log_level = "DEBUG"
data_dir = "/mnt/nomad"
datacenter = "TRITON_DC"
leave_on_terminate = true
bind_addr = "{{ GetPrivateIP }}"

server {
  enabled = true
  bootstrap_expect = 3
}

consul {
  server_service_name = "nomad"
  server_auto_join = true
  client_service_name = "nomad-client"
  client_auto_join = true
  auto_advertise = true
  address = "TRITON_CONSUL_CNS_URL:8500"
}
