variable "nomad_server_count" {
  description = "The number of nomad servers in the cluster"
  default = 3
}

variable "nomad_instance_package" {
  description = "The instance package to run nomad"
  default = "k4-general-kvm-3.75G"
}

variable "nomad_version" {
  description = "The version of the nomad server image"
  default = "0.7.1"
}

variable "nomad_image_name" {
  description = "The name of the nomad server image"
  default = "nomad-server"
}

variable "nomad_cns_tag" {
  default = "nomadserver"
}

variable "consul_cns_tag" {
  default = "consul"
}
