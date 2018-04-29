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

output "consul_cns_url" {
  value = "${var.consul_cns_url}"
}

output "cluster_name" {
  value = "${coalesce(var.cluster_name, format("%s-vault-cluster",
             var.instance_name_prefix))}"
}

output "secret_shares" {
  value = "${var.secret_shares}"
}

output "secret_threshold" {
  value = "${var.secret_threshold}"
}

output "psk_key" {
  value = "${random_string.mod.result}"
}

output "manta_path" {
  value = "${local.manta_path}"
}

output "private_cns_domain" {
  value = "${local.private_cns_domain}"
}
