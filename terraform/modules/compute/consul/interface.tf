variable "instance_count" {}
variable "instance_name_prefix" {}
variable "consul_image_id" {}
variable "package" {
  default = "k4-general-kvm-3.75G"
}

variable "networks" {
  type = "list"
}

variable "cns_service_tag" {
  default = "consul"
}