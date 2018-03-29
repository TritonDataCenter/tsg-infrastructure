resource "triton_vlan" "vlan" {
  vlan_id = "${var.vlan_id}"
  name = "${var.vlan_name}"
  description = "${var.vlan_description}"
}

resource "triton_fabric" "private_network" {
  name = "${var.network_name}"
  description = "${var.network_description}"
  vlan_id = "${triton_vlan.vlan.id}"

  subnet = "${var.private_subnet_cidr}"
  gateway = "${cidrhost(var.private_subnet_cidr, 1)}"
  provision_start_ip = "${cidrhost(var.private_subnet_cidr, 5)}"
  provision_end_ip = "${cidrhost(var.private_subnet_cidr, -5)}"

  internet_nat = "${var.internet_nat}"

  resolvers = ["${var.resolvers}"]
}

data "triton_network" "public" {
  name = "Joyent-SDC-Public"
}