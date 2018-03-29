variable "vlan_id" {}
variable "vlan_name" {}
variable "vlan_description" {}
variable "network_name" {}
variable "network_description" {}
variable "subnet_cidr" {}

variable "internet_nat" {
  default = true
}

variable "resolvers" {
  default = ["8.8.8.8","8.8.4.4"]
}