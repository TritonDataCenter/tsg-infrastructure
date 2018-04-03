output "public_network_id" {
  value = "${data.triton_network.mod.id}"
}

output "private_network_id" {
  value = "${triton_fabric.mod.id}"
}

output "subnet_cidr" {
  value = "${triton_fabric.mod.subnet}"
}

output "vlan_id" {
  value = "${triton_fabric.mod.vlan_id}"
}
