output "bastion_public_cns" {
  value = "${module.bastion.public_cns_domain}"
}

output "bastion_private_cns" {
  value = "${module.bastion.private_cns_domain}"
}

output "fabio_public_cns" {
  value = "${module.fabio.public_cns_domain}"
}

output "fabio_private_cns" {
  value = "${module.fabio.private_cns_domain}"
}

output "nomad_server_cns" {
  value = "${module.nomad_server.private_cns_domain}"
}

output "consul_server_cns" {
  value = "${module.consul.private_cns_domain}"
}

output "nomad_client_cns" {
  value = "${module.nomad_client.private_cns_domain}"
}

output "cockroach_db_cns" {
  value = "${module.cockroach.private_cns_domain}"
}

output "api_server_cns" {
  value = "${module.api_server.private_cns_domain}"
}

output "deployment_cns" {
  value = "${module.deployment.private_cns_domain}"
}
