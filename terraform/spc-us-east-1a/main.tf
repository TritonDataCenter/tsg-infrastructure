provider "triton" {}

terraform {
  backend "manta" {
    path = "us-east-1a/tsg"
  }
}

module "networking" {
  source = "../modules/networking"

  vlan_id = "215"
  vlan_name = "tsg"
  vlan_description = "TSG VLAN"

  subnet_cidr = "192.168.0.0/24"

  network_name = "tsg-private-network"
  network_description = "TSG Private Network"
}

module "bastion_hostname_cloud_config" {
  source = "../modules/common/hostname"

  name_prefix = "${var.instance_name_prefix}"
  instance_type = "bastion"
}

module "bastion" {
  source = "../modules/compute/bastion"

  name-prefix = "${var.instance_name_prefix}"
  image   = "${data.triton_image.tsg_base.id}"
  package = "${var.package}"

  firewall_enabled = "${var.firewall_enabled}"

  cloud_init_config = ["${module.bastion_hostname_cloud_config.rendered}"]

  networks = [
    "${module.networking.public_network_id}",
    "${module.networking.private_network_id}"
  ]

  firewall_targets_list = [
    "all vms",
    "any",
    "${formatlist("ip %s", var.allowed_ips)}",
    "${formatlist("subnet %s", var.allowed_cidr_blocks)}"
  ]
}

module "consul_hostname_cloud_config" {
  source = "../modules/common/hostname"

  name_prefix = "${var.instance_name_prefix}"
  instance_type = "consul"

  instance_count = "3"
}

module "consul" {
  source = "../modules/compute/consul"

  instance_count = "3"
  consul_image_id = "${data.triton_image.consul_base.id}"

  package = "${var.package}"
  instance_name_prefix = "${var.instance_name_prefix}"

  cloud_init_config = ["${module.consul_hostname_cloud_config.rendered}"]

  networks = [
    "${module.networking.private_network_id}"
  ]
}

module "nomad_server_hostname_cloud_config" {
  source = "../modules/common/hostname"

  name_prefix = "${var.instance_name_prefix}"
  instance_type = "nomad-server"

  instance_count = "3"
}

module "nomad_server" {
  source = "../modules/compute/nomad-server"

  instance_count = "3"
  nomad_server_image_id = "${data.triton_image.nomad_server_base.id}"

  package = "${var.package}"
  instance_name_prefix = "${var.instance_name_prefix}"

  cloud_init_config = ["${module.nomad_server_hostname_cloud_config.rendered}"]

  consul_cns_url = "${module.consul.private_cns_domain}"

  networks = [
    "${module.networking.private_network_id}"
  ]
}

module "nomad_client_hostname_cloud_config" {
  source = "../modules/common/hostname"

  name_prefix = "${var.instance_name_prefix}"
  instance_type = "nomad-client"

  instance_count = "3"
}

module "nomad_client" {
  source = "../modules/compute/nomad-client"

  instance_count = "3"
  nomad_client_image_id = "${data.triton_image.nomad_client_base.id}"

  package = "${var.package}"
  instance_name_prefix = "${var.instance_name_prefix}"

  cloud_init_config = ["${module.nomad_client_hostname_cloud_config.rendered}"]

  nomad_server_cns_url = "${module.nomad_server.private_cns_domain}"
  consul_cns_url = "${module.consul.private_cns_domain}"

  networks = [
    "${module.networking.private_network_id}"
  ]
}

module "cockroach_hostname_cloud_config" {
  source = "../modules/common/hostname"

  name_prefix = "${var.instance_name_prefix}"
  instance_type = "cockroach"

  instance_count = "3"
}

module "cockroach" {
  source = "../modules/compute/cockroach"

  name-prefix    = "${var.instance_name_prefix}"
  image   = "${data.triton_image.cockroach_base.id}"
  package = "${var.package}"

  insecure = true

  bastion_host = "${module.bastion.public_cns_domain}"
  cloud_init_config = ["${module.nomad_client_hostname_cloud_config.rendered}"]

  networks = [
    "${module.networking.private_network_id}"
  ]
}

data "triton_image" "tsg_base" {
  name        = "${var.tsg_base_image_name}"
  version     = "${var.tsg_base_image_version}"
  most_recent = true
}

data "triton_image" "consul_base" {
  name        = "${var.tsg_consul_image_name}"
  version     = "${var.tsg_consul_image_version}"
  most_recent = true
}

data "triton_image" "nomad_server_base" {
  name        = "${var.tsg_nomad_server_image_name}"
  version     = "${var.tsg_nomad_server_image_version}"
  most_recent = true
}

data "triton_image" "nomad_client_base" {
  name        = "${var.tsg_nomad_client_image_name}"
  version     = "${var.tsg_nomad_client_image_version}"
  most_recent = true
}

data "triton_image" "cockroach_base" {
  name        = "${var.tsg_cockroach_image_name}"
  version     = "${var.tsg_nomad_client_image_version}"
  most_recent = true
}
