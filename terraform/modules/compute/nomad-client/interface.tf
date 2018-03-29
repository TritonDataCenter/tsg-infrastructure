variable "instance_count" {}
variable "instance_name_prefix" {}
variable "nomad_client_image_id" {}
variable "consul_cns_url" {}
variable "nomad_server_cns_url" {}

variable "package" {
  default = "k4-general-kvm-3.75G"
}

variable "firewall_enabled" {
  default = false
}

variable "networks" {
  type = "list"
}

variable "cns_service_tag" {
  default = "nomadclient"
}

variable "cloud_init_config" {
  default = []
}