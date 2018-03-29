variable "name-prefix" {}
variable "image"   {}
variable "package" {}

variable "instances_count" {
  default = 1
}

variable "root_authorized_keys" {
  default = ""
}

variable "user_script" {
  default = []
}

variable "firewall_enabled" {
  default = false
}

variable "firewall_targets_list" {
  default = ["any"]
}

variable "networks" {
  type = "list"
}

variable "cns_service_tag" {
  default = "bastion"
}

variable "metadata" {
  default = {}
}

variable "tags" {
  default = {}
}

variable "cloud_init_config" {
  default = []
}
