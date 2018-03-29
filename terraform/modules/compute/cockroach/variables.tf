variable "name-prefix"    {}
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

variable "cloud_init_config" {
  default = []
}
