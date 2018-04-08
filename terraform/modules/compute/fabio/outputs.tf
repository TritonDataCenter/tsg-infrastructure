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

output "public_cns_domain" {
  value = "${local.public_cns_domain}"
}

output "private_cns_domain" {
  value = "${local.private_cns_domain}"
}

output "cloudflare_domain" {
  value = "${var.cloudflare_domain}"
}

output "cloudflare_record_ids" {
  value = [
    "${cloudflare_record.mod.*.id}",
  ]
}

output "cloudflare_record_name" {
  value = "${element(cloudflare_record.mod.*.hostname, 0)}"
}

output "cloudflare_zone_id" {
  value = "${element(cloudflare_record.mod.*.zone_id, 0)}"
}
