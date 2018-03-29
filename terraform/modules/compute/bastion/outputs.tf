output "image" {
  value = "${var.image}"
}

output "package" {
  value = "${var.package}"
}

output "instance_count" {
  value = "${var.instance_count}"
}

output "cns_service_tag" {
  value = "${var.cns_service_tag}"
}

output "networks" {
  value = [
    "${var.networks}",
  ]
}

output "ips" {
  value = [
    "${triton_machine.mod.*.ips}",
  ]
}

output "primaryip" {
  value = [
    "${triton_machine.mod.*.primaryip}",
  ]
}

output "public_cns_domain" {
  value = "${local.public_cns_domain}"
}

output "private_cns_domain" {
  value = "${local.private_cns_domain}"
}
