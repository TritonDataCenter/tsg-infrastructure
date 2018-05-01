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

variable "bastion_cns_url" {
  type = "string"
}

variable "cluster_name" {
  default = ""
}

variable "secret_shares" {
  default = 5
}

variable "secret_threshold" {
  default = 3
}

variable "psk_key_length" {
  default = 32
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
