variable "consul_server_count" {
  description = "The number of consul servers in the cluster"
  default = 3
}

variable "consul_instance_package" {
  description = "The instance package to run consul"
  default = "k4-general-kvm-3.75G"
}

variable "consul_version" {
  description = "The version of the consul server image"
  default = "1.0.6"
}

variable "consul_image_name" {
  description = "The name of the consul server image"
  default = "consul-server"
}

variable "consul_cns_tag" {
  default = "consul"
}
