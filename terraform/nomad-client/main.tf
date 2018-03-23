provider "triton" {}

resource "triton_machine" "nomad_client_blue" {
  count            = "${var.nomad_client_count}"
  name             = "${format("nomad-client%02d", count.index + 1)}"
  package          = "${var.nomad_instance_package}"
  image            = "${data.triton_image.nomad_client.id}"

  cns {
    services = ["${var.nomad_cns_tag}"]
  }

  affinity    = ["instance!=nomad*"]
  user_script = "${data.template_file.user_data.rendered}"
  networks    = ["${data.triton_network.private.id}",
                 "${data.triton_network.public.id}"]
}

data "triton_image" "nomad_client" {
  name        = "${var.nomad_image_name}"
  version     = "${var.nomad_version}"
  most_recent = true
}

data "triton_network" "private" {
  name = "Joyent-SDC-Private"
}

data "triton_network" "public" {
  name = "Joyent-SDC-Public"
}

data "triton_account" "main" {}

data "triton_datacenter" "current" {}

data "template_file" "user_data" {
  template = "${file("instance-user.conf")}"
  vars {
    dc = "${data.triton_datacenter.current.name}"
    cns_url = "${format("%s.svc.%s.%s.cns.joyent.com", var.consul_cns_tag, data.triton_account.main.id, data.triton_datacenter.current.name)}"
  }
}
