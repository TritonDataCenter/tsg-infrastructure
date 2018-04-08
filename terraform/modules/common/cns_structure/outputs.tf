output "cloud" {
  value = "${var.cloud}"
}

output "account_id" {
  value = "${data.triton_account.mod.id}"
}

output "datacenter" {
  value = "${data.triton_datacenter.mod.name}"
}

output "public_dns_fragment" {
  value = "${local.public_cns_fragment}"
}

output "private_dns_fragment" {
  value = "${local.private_cns_fragment}"
}
