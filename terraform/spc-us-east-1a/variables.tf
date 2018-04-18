variable "cloud" {
  default = "spc"
}

variable "instance_name_prefix" {
  default = "tsg"
}

variable "tsg_base_image_name" {
  default = "tsg-base"
}

variable "tsg_base_image_version" {
  default = "0.1.0"
}

variable "tsg_consul_image_name" {
  default = "tsg-consul-server"
}

variable "tsg_consul_image_version" {
  default = "1.0.6"
}

variable "tsg_nomad_server_image_name" {
  default = "tsg-nomad-server"
}

variable "tsg_nomad_server_image_version" {
  default = "0.7.1"
}

variable "tsg_nomad_client_image_name" {
  default = "tsg-nomad-client"
}

variable "tsg_nomad_client_image_version" {
  default = "0.7.1"
}

variable "tsg_cockroach_image_name" {
  default = "tsg-cockroach"
}

variable "tsg_cockroach_image_version" {
  default = "1.1.7"
}

variable "tsg_fabio_image_name" {
  default = "tsg-fabio"
}

variable "tsg_fabio_image_version" {
  default = "1.5.8"
}

variable "tsg_api_server_image_name" {
  default = "tsg-api-server"
}

variable "tsg_api_server_image_version" {
  default = "0.1.0"
}

variable "tsg_deployment_image_name" {
  default = "tsg-deployment"
}

variable "tsg_deployment_image_version" {
  default = "0.1.0"
}

variable "package" {
  default = "k4-general-kvm-3.75G"
}

variable "firewall_enabled" {
  default = false
}

variable "allowed_ips" {
  default = []
}

variable "allowed_cidr_blocks" {
  default = []
}
