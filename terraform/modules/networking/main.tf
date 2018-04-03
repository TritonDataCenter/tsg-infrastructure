data "triton_network" "mod" {
  name = "Joyent-SDC-Public"
}

resource "null_resource" "depends_on" {
  triggers {
    depends_on = "${join("", var.depends_on)}"
  }
}

resource "triton_vlan" "mod" {
  name        = "${var.vlan_name}"
  description = "${var.vlan_description}"
  vlan_id     = "${var.vlan_id}"
}

resource "triton_fabric" "mod" {
  name        = "${var.network_name}"
  description = "${var.network_description}"
  vlan_id     = "${triton_vlan.mod.id}"

  subnet             = "${var.subnet_cidr}"
  gateway            = "${cidrhost(var.subnet_cidr, 1)}"
  provision_start_ip = "${cidrhost(var.subnet_cidr, 5)}"
  provision_end_ip   = "${cidrhost(var.subnet_cidr, -5)}"

  internet_nat = "${var.internet_nat}"

  resolvers = [
    "${var.resolvers}",
  ]

  depends_on = [
    "null_resource.depends_on",
  ]
}
