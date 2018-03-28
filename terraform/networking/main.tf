provider "triton" {}

terraform {
  required_version = ">= 0.11.0"
  backend "manta" {
    path = "tsg-networking"
  }
}

resource "triton_vlan" "tsg" {
  vlan_id = "214"
  name = "tsg"
  description = "TSG Vlan"
}

resource "triton_fabric" "tsg_private_network" {
  name = "tsg-private-network"
  description = "TSG Private Network"
  vlan_id = "${triton_vlan.tsg.id}"

  subnet = "192.168.0.0/24"
  gateway = "192.168.0.1"
  provision_start_ip = "192.168.0.5"
  provision_end_ip = "192.168.0.250"

  internet_nat = true

  resolvers = ["8.8.8.8", "8.8.4.4"]
}

data "triton_network" "public" {
  name = "Joyent-SDC-Public"
}

output "public_network_id" {
  value = "${data.triton_network.public.id}"
}

output "private_network_id" {
  value = "${triton_fabric.tsg_private_network.id}"
}
