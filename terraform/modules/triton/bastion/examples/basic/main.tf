provider "triton" {}

data "triton_image" "ubuntu" {
  name        = "ubuntu-16.04-amd64"
  most_recent = true
}

data "triton_network" "public" {
  name = "Joyent-SDC-Public"
}

data "triton_network" "private" {
  name = "Joyent-SDC-Private"
}

module "origin" {
  source = "../../../../common/origin"

  add_cidr = false
}

module "bastion" {
  source = "../.."

  name    = "example"
  image   = "${data.triton_image.ubuntu.id}"
  package = "k4-general-kvm-3.75G"

  firewall_enabled = true

  networks = [
    "${data.triton_network.public.id}",
    "${data.triton_network.private.id}"
  ]

  firewall_targets_list = [
    "all vms",
    "${formatlist("ip %s", concat(list(module.origin.origin), var.allowed_ips))}",
    "${formatlist("subnet %s", var.allowed_cidr_blocks)}"
  ]



  tags = {
    "description" = "Example Bastion instance"
  }

}
