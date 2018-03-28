data "triton_image" "ubuntu" {
  name        = "${var.image_name}"
  version     = "${var.image_version}"
  most_recent = true
}

data "triton_network" "public" {
  name = "Joyent-SDC-Public"
}

data "triton_network" "private" {
  name = "Joyent-SDC-Private"
}

module "bastion" {
  source = "../modules/triton/bastion"

  name    = "${var.name}"
  image   = "${data.triton_image.ubuntu.id}"
  package = "${var.package}"

  firewall_enabled = true

  networks = [
    "${data.triton_network.public.id}",
    "${data.triton_network.private.id}"
  ]

  firewall_targets_list = [
    "all vms",
    "any",
    "${formatlist("ip %s", var.allowed_ips)}",
    "${formatlist("subnet %s", var.allowed_cidr_blocks)}"
  ]
}
