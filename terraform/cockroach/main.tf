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

module "cockroach" {
  source = "../modules/triton/cockroach"

  name    = "${var.name}"
  image   = "${data.triton_image.ubuntu.id}"
  package = "${var.package}"

  insecure = true

  bastion_host = "${data.terraform_remote_state.bastion.public_cns_domain}"

  networks = [
    "${data.triton_network.public.id}",
    "${data.triton_network.private.id}"
  ]
}
