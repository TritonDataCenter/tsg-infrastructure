output "image" {
  value = "${var.image}"
}

output "package" {
  value = "${var.package}"
}

output "cns_service_tag" {
  value = "${var.cns_service_tag}"
}

output "ips" {
  value = ["${triton_machine.mod.*.ips}"]
}

output "primaryip" {
  value = ["${triton_machine.mod.*.primaryip}"]
}

output "domain_names" {
  value = ["${local.domain_names}"]
}
