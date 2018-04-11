output "cloud" {
  value = "${var.cloud}"
}

output "datacenter" {
  value = "${var.datacenter}"
}

output "manta_endpoint" {
  value = "${local.manta_endpoint}"
}

output "manta_url" {
  value = "${local.manta_url}"
}
