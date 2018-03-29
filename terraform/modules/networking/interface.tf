variable "vlan_name" {
  type = "string"
}

variable "vlan_description" {
  type = "string"
}

variable "vlan_id" {
  type = "string"
}

variable "network_name" {
  type = "string"
}

variable "network_description" {
  type = "string"
}

variable "subnet_cidr" {
  type = "string"
}

variable "internet_nat" {
  default = true
}

variable "resolvers" {
  default = [
    "8.8.8.8",
    "4.2.2.2",
  ]
}

variable "depends_on" {
  default = []
}
