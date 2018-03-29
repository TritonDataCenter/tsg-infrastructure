variable "vlan_id" {
  type = "string"
}

variable "vlan_name" {
  type = "string"
}

variable "vlan_description" {
  type = "string"
}


variable "network_name" {
  type = "string"
}

variable "network_description" {
  type = "string"
}

variable "private_subnet_cidr" {
  type = "string"
}

variable "internet_nat" {
  type = "string"
  default = "true"
}

variable "resolvers" {
  type = "list"
  default = ["8.8.8.8","8.8.4.4"]
}