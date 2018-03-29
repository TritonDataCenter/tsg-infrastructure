output "private_network_id" {
  value = "${triton_fabric.private_network.id}"
}

output "public_network_id" {
  value = "${data.triton_network.public.id}"
}