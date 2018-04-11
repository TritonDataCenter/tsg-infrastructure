variable "cloud" {
  default = "jpc"
}

variable "private_cns_fragment" {
  type = "string"
}

variable "public_cns_fragment" {
  type = "string"
}

variable "cloudflare_domain" {
  type = "string"
}

variable "cloudflare_name" {
  type = "string"
}

variable "cloudflare_ttl" {
  default = 1
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
  default = 2
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

variable "certificate_san" {
  default = []
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
  default = "fabio"
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
