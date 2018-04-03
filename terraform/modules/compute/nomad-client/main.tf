locals {
  private_cns_domain = "${format("%s.%s", var.cns_service_tag, var.cns_fragment)}"
}

data "triton_datacenter" "mod" {}

data "template_file" "mod" {
  count = "${var.instance_count}"

  template = "${file(format("%s/templates/%s", path.module, "user_script.sh.tpl"))}"

  vars {
    data_center_name = "${data.triton_datacenter.mod.name}"
    consul_cns_url   = "${var.consul_cns_url}"
    nomad_cns_url    = "${var.nomad_cns_url}"
  }
}

resource "null_resource" "depends_on" {
  triggers {
    depends_on = "${join("", flatten(var.depends_on))}"
  }
}

resource "triton_machine" "mod" {
  count = "${var.instance_count}"

  name    = "${format("%s-nomad-client-%02d", var.instance_name_prefix, count.index + 1)}"
  package = "${var.package}"
  image   = "${var.image}"

  root_authorized_keys = "${var.root_authorized_keys}"

  cloud_config = "${length(var.cloud_init_config) > 0 ?
                    element(concat(var.cloud_init_config, list("")),
                    count.index) : ""}"

  user_script = "${element(coalescelist(var.user_script,
                   data.template_file.mod.*.rendered),
                   count.index)}"

  firewall_enabled = "${var.firewall_enabled}"

  networks = [
    "${var.networks}",
  ]

  affinity = [
    "${format("instance!=~%s-nomad-client-*", var.instance_name_prefix)}",
  ]

  cns {
    services = [
      "${var.cns_service_tag}",
    ]
  }

  metadata = "${var.metadata}"

  tags = "${merge(map(
    "name", "${format("%s-nomad-client-%02d", var.instance_name_prefix, count.index + 1)}"
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
