data "triton_image" "ubuntu" {
  name        = "${var.image_name}"
  version     = "${var.image_version}"
  most_recent = true
}

module "bastion" {
  source = "../modules/triton/bastion"

  name    = "${var.name}"
  image   = "${data.triton_image.ubuntu.id}"
  package = "${var.package}"

  firewall_enabled = true

  networks = [
    "${data.terraform_remote_state.networking.public_network_id}",
    "${data.terraform_remote_state.networking.private_network_id}"
  ]

  firewall_targets_list = [
    "all vms",
    "any",
    "${formatlist("ip %s", var.allowed_ips)}",
    "${formatlist("subnet %s", var.allowed_cidr_blocks)}"
  ]
}
