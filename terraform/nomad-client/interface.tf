variable "nomad_client_count" {
  description = "The number of nomad servers in the cluster"
  default = 3
}

variable "nomad_instance_package" {
  description = "The instance package to run nomad"
  default = "k4-general-kvm-3.75G"
}

variable "nomad_version" {
  description = "The version of the nomad client image"
  default = "0.7.1"
}

variable "nomad_image_name" {
  description = "The name of the nomad client image"
  default = "nomad-client"
}

variable "nomad_cns_tag" {
  default = "nomadclient"
}

variable "consul_cns_tag" {
  default = "consul"
}
