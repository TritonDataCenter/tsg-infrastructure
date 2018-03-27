locals {
  domain_names = [
    "${format("%s.svc.%s.%s.triton.zone", var.cns_service_tag,
       data.triton_account.mod.id, data.triton_datacenter.mod.name)}",
    "${format("%s.svc.%s.%s.cns.joyent.com", var.cns_service_tag,
       data.triton_account.mod.id, data.triton_datacenter.mod.name)}"
  ]
}

data "triton_account" "mod" {}

data "triton_datacenter" "mod" {}

data "template_file" "mod" {
  count = "${var.instances_count}"

  template = "${file(format("%s/templates/%s", path.module, "cloud-config.tpl"))}"

  vars {
    hostname = "${format("%s-bastion-%02d", var.name, count.index + 1)}"
  }
}

data "template_cloudinit_config" "mod" {
  count = "${var.instances_count}"

  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.cfg"
    content_type = "text/cloud-config"
    content      = "${coalesce(var.cloud_config, element(
                      data.template_file.mod.*.rendered,
                      count.index))}"
  }

  part {
    filename     = "cloud_init_user_data.sh"
    content_type = "text/x-shellscript"
    content      = "${var.cloud_init_user_data}"
  }
}

resource "triton_machine" "mod" {
  count = "${var.instances_count}"

  name    = "${format("%s-bastion-%02d", var.name, count.index + 1)}"
  package = "${var.package}"
  image   = "${var.image}"

  cloud_config = "${coalesce(var.cloud_config, element(
                    data.template_cloudinit_config.mod.*.rendered,
                    count.index))}"

  user_script = "${var.user_script}"

  firewall_enabled = "${var.firewall_enabled}"

  networks = [
    "${var.networks}"
  ]

  affinity = [
    "${format("instance!=~/^%s-bastion-\\d+/", var.name)}"
  ]

  cns {
    services = [
      "${var.cns_service_tag}"
    ]
  }

  metadata = "${var.metadata}"

  tags = "${merge(map(
      "name", "${format("%s-bastion-%02d", var.name, count.index + 1)}"
    ), var.tags)}"
}

resource "triton_firewall_rule" "mod" {
  count = "${var.firewall_enabled ? length(var.firewall_targets_list) : 0}"

  enabled     = true
  description = "${format("Allow SSH to Bastion - %s", var.name)}"

  rule = "FROM ${var.firewall_targets_list[count.index]} TO tag \"triton.cns.services\" = \"${var.cns_service_tag}\" ALLOW tcp PORT 22"
}
