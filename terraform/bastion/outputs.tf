output "ips" {
  value = ["${module.bastion.ips}"]
}

output "primaryip" {
  value = ["${module.bastion.primaryip}"]
}

output "domain_names" {
  value = ["${module.bastion.domain_names}"]
}
