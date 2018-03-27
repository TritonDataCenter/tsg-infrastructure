variable "name"    {}
variable "image"   {}
variable "package" {}

variable "insecure" {
  default = false
}

variable "instances_count" {
  default = 3
}

variable "root_authorized_keys" {
  default = ""
}

variable "bastion_host" {
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
