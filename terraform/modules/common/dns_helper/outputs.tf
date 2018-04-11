output "cloud" {
  value = "${var.cloud}"
}

output "datacenter" {
  value = "${data.triton_datacenter.mod.name}"
}

output "domain_name" {
  value = "${local.domain_name}"
}

output "fqdn" {
  value = "${local.fqdn}"
}
