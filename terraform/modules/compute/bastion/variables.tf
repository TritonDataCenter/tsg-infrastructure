variable "name"    {}
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

variable "cloud_config" {
  default = []
}

variable "cloud_init_user_data" {
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
