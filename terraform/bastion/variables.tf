variable "name" {
  default = "tsg"
}

variable "image_name" {
  default = "tsg-base"
}

variable "image_version" {
  default = "0.1.0"
}

variable "package" {
  default= "k4-general-kvm-3.75G"
}

variable "firewall_enabled" {
  default = false
}

variable "allowed_ips" {
  default = []
}

variable "allowed_cidr_blocks" {
  default = []
}
