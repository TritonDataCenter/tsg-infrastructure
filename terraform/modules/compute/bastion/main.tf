locals {
  private_cns_domain = "${format("%s.%s", var.cns_service_tag,
                          var.private_cns_fragment)}"

  public_cns_domain = "${format("%s.%s", var.cns_service_tag,
                         var.public_cns_fragment)}"
}

resource "null_resource" "depends_on" {
  triggers {
    depends_on = "${join("", flatten(var.depends_on))}"
  }
}

resource "triton_machine" "mod" {
  count = "${var.instance_count}"

  name    = "${format("%s-bastion-%02d", var.instance_name_prefix, count.index + 1)}"
  package = "${var.package}"
  image   = "${var.image}"

  root_authorized_keys = "${var.root_authorized_keys}"

  cloud_config = "${length(var.cloud_init_config) > 0 ?
                    element(concat(var.cloud_init_config, list("")),
                    count.index) : ""}"

  user_script = "${length(var.user_script) > 0 ?
                   element(concat(var.user_script, list("")),
                   count.index) : ""}"

  firewall_enabled = "${var.firewall_enabled}"

  networks = [
    "${var.networks}",
  ]

  affinity = [
    "${format("instance!=~%s-bastion-*", var.instance_name_prefix)}",
  ]

  cns {
    services = [
      "${var.cns_service_tag}",
    ]
  }

  metadata = "${var.metadata}"

  tags = "${merge(map(
    "name", "${format("%s-bastion-%02d", var.instance_name_prefix, count.index + 1)}"
  ), var.tags)}"

  depends_on = [
    "null_resource.depends_on",
  ]

  lifecycle {
    ignore_changes = [
      "image",
      "tags",
    ]
  }
}

resource "triton_firewall_rule" "mod" {
  count = "${var.firewall_enabled ? length(var.firewall_targets_list) : 0}"

  enabled = true

  description = "${format("Allow SSH to Bastion from %s - %s",
                   element(var.firewall_targets_list, count.index),
                   var.instance_name_prefix)}"

  rule = "${format("FROM %s TO tag \"triton.cns.services\" = \"%s\" ALLOW tcp PORT 22",
            element(var.firewall_targets_list, count.index), var.cns_service_tag)}"

  depends_on = [
    "triton_machine.mod",
  ]
}
