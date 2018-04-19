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
  default = 1
}

variable "cockroach_insecure" {
  default = "false"
}

variable "cockroach_cns_url" {
  type = "string"
}

variable "nomad_cns_url" {
  type = "string"
}

variable "nomad_role" {
  default = "deployment"
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

variable "networks" {
  type = "list"
}

variable "cns_service_tag" {
  default = "deployment"
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
