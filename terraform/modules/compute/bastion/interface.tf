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
  default = 1
}

variable "root_authorized_keys" {
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

variable "depends_on" {
  default = []
}
