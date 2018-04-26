locals {
  private_cns_domain = "${format("%s.%s", var.cns_service_tag,
                          var.private_cns_fragment)}"
}

data "triton_datacenter" "mod" {}

data "template_file" "mod" {
  count = "${var.instance_count}"

  template = "${file(format("%s/templates/%s", path.module, "user_script.sh.tpl"))}"

  vars {
    data_center_name = "${data.triton_datacenter.mod.name}"
    consul_cns_url   = "${var.consul_cns_url}"

    cluster_name = "${coalesce(var.cluster_name, format("%s-vault-cluster",
                      var.instance_name_prefix))}"
  }
}

resource "null_resource" "depends_on" {
  triggers {
    depends_on = "${join("", flatten(var.depends_on))}"
  }
}

module "manta_url" {
  source = "../../common/env"

  name = "MANTA_URL"
}

module "triton_account" {
  source = "../../common/env"

  name = "TRITON_ACCOUNT"
}

module "triton_key_id" {
  source = "../../common/env"

  name = "TRITON_KEY_ID"
}

module "manta_helper" {
  source = "../../common/manta_helper"

  cloud = "${var.cloud}"
}

resource "triton_machine" "mod" {
  count = "${var.instance_count}"

  name    = "${format("%s-vault-%02d", var.instance_name_prefix, count.index + 1)}"
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
    "${format("instance!=~%s-vault-*", var.instance_name_prefix)}",
  ]

  cns {
    services = [
      "${var.cns_service_tag}",
    ]
  }

  metadata = "${var.metadata}"

  tags = "${merge(map(
    "name", "${format("%s-vault-%02d", var.instance_name_prefix, count.index + 1)}"
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

resource "null_resource" "mod" {
  count = "${var.instance_count}"

  triggers {
    vault_instance_ids = "${join(",", triton_machine.mod.*.id)}"
  }

  connection {
    type         = "ssh"
    user         = "ubuntu"
    host         = "${element(triton_machine.mod.*.primaryip, count.index)}"
    bastion_host = "${var.bastion_cns_url}"
    timeout      = "120s"
  }

  provisioner "remote-exec" {
    scripts = [
      "${format("%s/files/%s", path.module, "configure.sh")}",
      "${format("%s/files/%s", path.module, "start.sh")}",
    ]
  }
}
