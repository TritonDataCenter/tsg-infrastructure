variable "cloud" {
  default = "jpc"
}

variable "private_cns_fragment" {
  type = "string"
}

variable "instance_name_prefix" {
  type = "string"
}

variable "image" {
  type = "string"
}

variable "package" {
  type = "string"
}

variable "instance_count" {
  default = 3
}

variable "consul_cns_url" {
  type = "string"
}

variable "cluster_name" {
  default = ""
}

variable "root_authorized_keys" {
  default = ""
}

variable "bastion_cns_url" {
  default = ""
}

variable "cloud_init_config" {
  default = []
}

variable "user_script" {
  default = []
}

variable "firewall_enabled" {
  default = false
}

variable "networks" {
  type = "list"
}

variable "cns_service_tag" {
  default = "vault"
}

variable "metadata" {
  default = {}
}

variable "tags" {
  default = {}
}

variable "depends_on" {
  default = []
}
