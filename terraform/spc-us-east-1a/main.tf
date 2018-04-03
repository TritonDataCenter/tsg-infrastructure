provider "triton" {}

terraform {
  backend "manta" {
    path = "us-east-1a/tsg"
    url = "https://us-east.manta.samsungcloud.io"
  }
}

data "triton_image" "bastion" {
  name        = "${var.tsg_base_image_name}"
  version     = "${var.tsg_base_image_version}"
  most_recent = true
}

data "triton_image" "consul" {
  name        = "${var.tsg_consul_image_name}"
  version     = "${var.tsg_consul_image_version}"
  most_recent = true
}

data "triton_image" "nomad_server" {
  name        = "${var.tsg_nomad_server_image_name}"
  version     = "${var.tsg_nomad_server_image_version}"
  most_recent = true
}

data "triton_image" "nomad_client" {
  name        = "${var.tsg_nomad_client_image_name}"
  version     = "${var.tsg_nomad_client_image_version}"
  most_recent = true
}

data "triton_image" "cockroach" {
  name        = "${var.tsg_cockroach_image_name}"
  version     = "${var.tsg_cockroach_image_version}"
  most_recent = true
}

data "triton_image" "fabio" {
  name        = "${var.tsg_fabio_image_name}"
  version     = "${var.tsg_fabio_image_version}"
  most_recent = true
}

module "cns_fragments" {
  source = "../modules/common/cns_structure"

  cloud = "spc"
}

module "networking" {
  source = "../modules/networking"

  vlan_name        = "tsg"
  vlan_description = "TSG VLAN"
  vlan_id          = 215

  subnet_cidr = "192.168.0.0/24"

  network_name        = "tsg-private-network"
  network_description = "TSG Private Network"
}

module "bastion_hostname_cloud_config" {
  source = "../modules/common/hostname"

  instance_count = 2

  instance_name_prefix = "${var.instance_name_prefix}"
  instance_type        = "bastion"
}

module "bastion" {
  source = "../modules/compute/bastion"

  instance_count = 2

  instance_name_prefix = "${var.instance_name_prefix}"
  image                = "${data.triton_image.bastion.id}"
  package              = "${var.package}"

  firewall_enabled = "${var.firewall_enabled}"

  private_cns_fragment = "${module.cns_fragments.private_dns_fragment}"
  public_cns_fragment = "${module.cns_fragments.public_dns_fragment}"

  cloud_init_config = [
    "${module.bastion_hostname_cloud_config.rendered}",
  ]

  networks = [
    "${module.networking.public_network_id}",
    "${module.networking.private_network_id}",
  ]

  firewall_targets_list = [
    "all vms",
    "any",
    "${formatlist("ip %s", var.allowed_ips)}",
    "${formatlist("subnet %s", var.allowed_cidr_blocks)}",
  ]
}

module "consul_hostname_cloud_config" {
  source = "../modules/common/hostname"

  instance_count = 3

  instance_name_prefix = "${var.instance_name_prefix}"
  instance_type        = "consul"
}

module "consul" {
  source = "../modules/compute/consul"

  instance_count = 3

  instance_name_prefix = "${var.instance_name_prefix}"
  package              = "${var.package}"
  image                = "${data.triton_image.consul.id}"

  cns_fragment = "${module.cns_fragments.private_dns_fragment}"

  cloud_init_config = [
    "${module.consul_hostname_cloud_config.rendered}",
  ]

  networks = [
    "${module.networking.private_network_id}",
  ]
}

module "cockroach_hostname_cloud_config" {
  source = "../modules/common/hostname"

  instance_count = 3

  instance_name_prefix = "${var.instance_name_prefix}"
  instance_type        = "cockroach"
}

module "cockroach" {
  source = "../modules/compute/cockroach"

  instance_count = 3

  instance_name_prefix = "${var.instance_name_prefix}"
  image                = "${data.triton_image.cockroach.id}"
  package              = "${var.package}"

  insecure = true

  cns_fragment = "${module.cns_fragments.private_dns_fragment}"
  consul_cns_url       = "${module.consul.private_cns_domain}"
  bastion_cns_url = "${module.bastion.public_cns_domain}"

  cloud_init_config = [
    "${module.cockroach_hostname_cloud_config.rendered}",
  ]

  networks = [
    "${module.networking.private_network_id}",
  ]

  depends_on = [
    "${module.consul.ips}",
  ]
}

module "nomad_server_hostname_cloud_config" {
  source = "../modules/common/hostname"

  instance_count = 3

  instance_name_prefix = "${var.instance_name_prefix}"
  instance_type        = "nomad-server"
}

module "nomad_server" {
  source = "../modules/compute/nomad-server"

  instance_count = 3

  instance_name_prefix = "${var.instance_name_prefix}"
  package              = "${var.package}"
  image                = "${data.triton_image.nomad_server.id}"

  cns_fragment = "${module.cns_fragments.private_dns_fragment}"
  consul_cns_url = "${module.consul.private_cns_domain}"

  cloud_init_config = [
    "${module.nomad_server_hostname_cloud_config.rendered}",
  ]

  networks = [
    "${module.networking.private_network_id}",
  ]

  depends_on = [
    "${module.consul.ips}",
  ]
}

module "nomad_client_hostname_cloud_config" {
  source = "../modules/common/hostname"

  instance_count = 3

  instance_name_prefix = "${var.instance_name_prefix}"
  instance_type        = "nomad-client"
}

module "nomad_client" {
  source = "../modules/compute/nomad-client"

  instance_count = 3

  instance_name_prefix = "${var.instance_name_prefix}"
  package              = "${var.package}"
  image                = "${data.triton_image.nomad_client.id}"

  cns_fragment = "${module.cns_fragments.private_dns_fragment}"
  consul_cns_url = "${module.consul.private_cns_domain}"
  nomad_cns_url  = "${module.nomad_server.private_cns_domain}"

  cloud_init_config = [
    "${module.nomad_client_hostname_cloud_config.rendered}",
  ]

  networks = [
    "${module.networking.private_network_id}",
  ]

  depends_on = [
    "${module.consul.ips}",
    "${module.nomad_server.ips}",
  ]
}

module "fabio_hostname_cloud_config" {
  source = "../modules/common/hostname"

  instance_count = 2

  instance_name_prefix = "${var.instance_name_prefix}"
  instance_type        = "fabio"
}

module "fabio" {
  source = "../modules/compute/fabio"

  instance_count = 2

  instance_name_prefix = "${var.instance_name_prefix}"
  image                = "${data.triton_image.fabio.id}"
  package              = "${var.package}"

  private_cns_fragment = "${module.cns_fragments.private_dns_fragment}"
  public_cns_fragment = "${module.cns_fragments.public_dns_fragment}"
  consul_cns_url       = "${module.consul.private_cns_domain}"

  cloud_init_config = [
    "${module.fabio_hostname_cloud_config.rendered}",
  ]

  networks = [
    "${module.networking.public_network_id}",
    "${module.networking.private_network_id}",
  ]

  depends_on = [
    "${module.consul.ips}",
    "${module.nomad_server.ips}",
  ]
}
