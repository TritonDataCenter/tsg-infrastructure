log_level = "DEBUG"
data_dir = "/mnt/nomad"
leave_on_terminate = true

datacenter = "TRITON_DC"

client {
  enabled = true
}

consul {
  server_service_name = "nomad"
  server_auto_join = true
  client_service_name = "nomad-client"
  client_auto_join = true
  auto_advertise = true
  address = "TRITON_CONSUL_CNS_URL:8500"
}
