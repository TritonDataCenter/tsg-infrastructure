output "networks" {
  value = [
    "${module.bastion.networks}"
  ]
}

output "ips" {
  value = [
    "${module.bastion.ips}"
  ]
}

output "primaryip" {
  value = [
    "${module.bastion.primaryip}"
  ]
}

output "public_cns_domain" {
  value = "${module.bastion.public_cns_domain}"
}

output "private_cns_domain" {
  value = "${module.bastion.private_cns_domain}"
}
