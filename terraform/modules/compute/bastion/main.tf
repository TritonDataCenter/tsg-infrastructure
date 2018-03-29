locals {
  public_cns_domain = "${format("%s.svc.%s.%s.triton.zone", var.cns_service_tag,
                         data.triton_account.mod.id, data.triton_datacenter.mod.name)}",

  private_cns_domain = "${format("%s.svc.%s.%s.cns.joyent.com", var.cns_service_tag,
                          data.triton_account.mod.id, data.triton_datacenter.mod.name)}"
}

data "triton_account" "mod" {}

data "triton_datacenter" "mod" {}

resource "triton_machine" "mod" {
  count = "${var.instances_count}"

  name    = "${format("%s-bastion-%02d", var.name-prefix, count.index + 1)}"
  package = "${var.package}"
  image   = "${var.image}"

  cloud_config = "${element(var.cloud_init_config,count.index)}"

  user_script = "${length(var.user_script) > 0 ?
                   element(concat(var.user_script, list("")),
                   count.index) : ""}"

  firewall_enabled = "${var.firewall_enabled}"

  networks = [
    "${var.networks}"
  ]

  affinity = [
    "${format("instance!=~/^%s-bastion-\\d+/", var.name-prefix)}"
  ]

  cns {
    services = [
      "${var.cns_service_tag}"
    ]
  }

  metadata = "${var.metadata}"

  tags = "${merge(map(
      "name", "${format("%s-bastion-%02d", var.name-prefix, count.index + 1)}"
    ), var.tags)}"
}

resource "triton_firewall_rule" "mod" {
  count = "${var.firewall_enabled ? length(var.firewall_targets_list) : 0}"

  enabled     = true
  description = "${format("Allow SSH to Bastion from %s - %s",
                   var.firewall_targets_list[count.index],
                   var.name-prefix)}"

  rule = "FROM ${var.firewall_targets_list[count.index]} TO tag \"triton.cns.services\" = \"${var.cns_service_tag}\" ALLOW tcp PORT 22"
}
