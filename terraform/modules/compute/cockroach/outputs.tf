output "image" {
  value = "${var.image}"
}

output "package" {
  value = "${var.package}"
}

output "insecure" {
  value = "${var.insecure ? "true" : "false"}"
}

output "cns_service_tag" {
  value = "${var.cns_service_tag}"
}

output "networks" {
  value = [
    "${var.networks}"
  ]
}

output "ips" {
  value = [
    "${triton_machine.mod.*.ips}"
  ]
}

output "primaryip" {
  value = [
    "${triton_machine.mod.*.primaryip}"
  ]
}

output "private_cns_domain" {
  value = "${local.private_cns_domain}"
}
