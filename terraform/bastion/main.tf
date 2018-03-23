provider "triton" {}

terraform {
  required_version = ">= 0.11.0"
  backend "manta" {
    path = "tsg-bastion"
  }
}

data "triton_image" "ubuntu" {
  name        = "tsg-base"
  version     = "0.1.0"
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

  name    = "tsg"
  image   = "${data.triton_image.ubuntu.id}"
  package = "k4-general-kvm-3.75G"

  firewall_enabled = true

  networks = [
    "${data.triton_network.public.id}",
    "${data.triton_network.private.id}"
  ]

  firewall_targets_list = [
    "all vms",
    "any"
  ]
}
