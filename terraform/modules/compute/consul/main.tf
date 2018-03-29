locals {
  private_cns_domain = "${format("%s.svc.%s.%s.cns.joyent.com", var.cns_service_tag,
                          data.triton_account.mod.id, data.triton_datacenter.mod.name)}"
}

resource "triton_machine" "mod" {
  count            = "${var.instance_count}"
  name             = "${format("%s-consul-%02d", var.instance_name_prefix, count.index + 1)}"
  package          = "${var.package}"
  image            = "${var.consul_image_id}"

  cloud_config = "${element(var.cloud_init_config,count.index)}"

  cns {
    services = ["${var.cns_service_tag}"]
  }

  tags {
    name = "${format("%s-consul-%02d", var.instance_name_prefix, count.index + 1)}"
  }

  firewall_enabled = "${var.firewall_enabled}"

  affinity    = ["instance!=consul*"]
  user_script = "${element(
                   data.template_file.user_data.*.rendered,
                   count.index)}"

  networks    = ["${var.networks}"]
}

data "template_file" "user_data" {
  count = "${var.instance_count}"

  template = "${file(format("%s/templates/%s", path.module, "user_data.tpl"))}"

  vars {
    dc = "${data.triton_datacenter.mod.name}"
    cns_url = "${local.private_cns_domain}"
  }
}

data "triton_account" "mod" {}

data "triton_datacenter" "mod" {}