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

variable "insecure" {
  default = false
}

variable "consul_cns_url" {
  type = "string"
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
  default = "cockroach"
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
