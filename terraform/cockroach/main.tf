data "triton_image" "ubuntu" {
  name        = "${var.image_name}"
  version     = "${var.image_version}"
  most_recent = true
}

module "cockroach" {
  source = "../modules/triton/cockroach"

  name    = "${var.name}"
  image   = "${data.triton_image.ubuntu.id}"
  package = "${var.package}"

  insecure = true

  bastion_host = "${data.terraform_remote_state.bastion.public_cns_domain}"

  networks = [
    "${data.terraform_remote_state.networking.private_network_id}"
  ]
}
