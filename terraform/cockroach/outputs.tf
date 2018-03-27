output "insecure" {
  value = "${module.cockroach.insecure}"
}

output "ips" {
  value = ["${module.cockroach.ips}"]
}

output "primaryip" {
  value = ["${module.cockroach.primaryip}"]
}

output "public_cns_domain" {
  value = ["${module.cockroach.public_cns_domain}"]
}

output "private_cns_domain" {
  value = ["${module.cockroach.private_cns_domain}"]
}
