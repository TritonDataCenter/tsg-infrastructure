log_level = "DEBUG"
data_dir = "/mnt/nomad"
leave_on_terminate = true

datacenter = "TRITON_DC"

client {
  enabled = true
  servers = ["TRITON_NOMAD_CNS_URL"]
}
