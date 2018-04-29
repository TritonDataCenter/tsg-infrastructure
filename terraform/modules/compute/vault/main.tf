locals {
  private_cns_domain = "${format("%s.%s", var.cns_service_tag,
                          var.private_cns_fragment)}"

  manta_path = "${format("/%s/stor/vault/%s/%s",
                  data.triton_account.mod.login, var.cloud,
                  data.triton_datacenter.mod.name)}"
}

data "triton_account" "mod" {}

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

resource "random_string" "mod" {
  length = "${var.psk_key_length}"
}

resource "random_shuffle" "mod" {
  input = [
    "${triton_machine.mod.*.primaryip}",
  ]

  result_count = 1
}

resource "null_resource" "bootstrap" {
  count = "${var.instance_count}"

  triggers {
    vault_instance_ids = "${join(",", triton_machine.mod.*.id)}"
  }

  connection {
    type         = "ssh"
    user         = "ubuntu"
    host         = "${element(triton_machine.mod.*.primaryip, count.index)}"
    bastion_host = "${var.bastion_cns_url}"
    timeout      = "180s"
  }

  provisioner "remote-exec" {
    scripts = [
      "${format("%s/files/%s", path.module, "configure.sh")}",
      "${format("%s/files/%s", path.module, "start.sh")}",
    ]
  }
}

resource "null_resource" "initialize" {
  triggers {
    vault_instance_ids = "${join(",", triton_machine.mod.*.id)}"
  }

  connection {
    type         = "ssh"
    user         = "ubuntu"
    host         = "${element(random_shuffle.mod.result, 0)}"
    bastion_host = "${var.bastion_cns_url}"
    timeout      = "180s"
  }

  provisioner "file" {
    content = <<EOF
export MANTA_URL='${coalesce(module.manta_url.value, module.manta_helper.manta_url)}'
export MANTA_USER='${module.triton_account.value}'
export MANTA_KEY_ID='${module.triton_key_id.value}'
export MANTA_PATH='${local.manta_path}'
EOF

    destination = "/var/tmp/.manta"
  }

  provisioner "file" {
    content = <<EOF
export SECRET_SHARES='${var.secret_shares}'
export SECRET_THRESHOLD='${var.secret_threshold}'
EOF

    destination = "/var/tmp/.vault"
  }

  provisioner "file" {
    source      = "${format("%s/files/%s", path.module, "initialize.sh")}"
    destination = "/var/tmp/initialize.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 755 /var/tmp/initialize.sh",
      "${format("PSK_KEY='%s' /var/tmp/initialize.sh", random_string.mod.result)}",
      "rm -f /var/tmp/initialize.sh",
    ]
  }

  depends_on = [
    "null_resource.bootstrap",
  ]
}

resource "null_resource" "unseal" {
  count = "${var.instance_count}"

  triggers {
    vault_instance_ids = "${join(",", triton_machine.mod.*.id)}"
  }

  connection {
    type         = "ssh"
    user         = "ubuntu"
    host         = "${element(triton_machine.mod.*.primaryip, count.index)}"
    bastion_host = "${var.bastion_cns_url}"
    timeout      = "180s"
  }

  provisioner "file" {
    content = <<EOF
export MANTA_URL='${coalesce(module.manta_url.value, module.manta_helper.manta_url)}'
export MANTA_USER='${module.triton_account.value}'
export MANTA_KEY_ID='${module.triton_key_id.value}'
export MANTA_PATH='${local.manta_path}'
EOF

    destination = "/var/tmp/.manta"
  }

  provisioner "file" {
    source      = "${format("%s/files/%s", path.module, "unseal.sh")}"
    destination = "/var/tmp/unseal.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 755 /var/tmp/unseal.sh",
      "${format("PSK_KEY='%s' /var/tmp/unseal.sh", random_string.mod.result)}",
      "rm -f /var/tmp/unseal.sh",
    ]
  }

  depends_on = [
    "null_resource.initialize",
  ]
}

resource "triton_firewall_rule" "firewall_allow_ingress_ssh" {
  count = "${var.firewall_enabled ? length(var.firewall_targets_list) : 0}"

  enabled = true

  description = "${format("Allow SSH to Vault from %s - %s",
                   element(var.firewall_targets_list, count.index),
                   var.instance_name_prefix)}"

  rule = "${format("FROM %s TO tag \"triton.cns.services\" = \"%s\" ALLOW tcp PORT 22",
            element(var.firewall_targets_list, count.index), var.cns_service_tag)}"

  depends_on = [
    "triton_machine.mod",
  ]
}

resource "triton_firewall_rule" "firewall_allow_ingress_8080" {
  count = "${var.firewall_enabled ? 1 : 0}"

  enabled = true

  description = "${format("Allow TCP/8080 to Vault - %s",
                   var.instance_name_prefix)}"

  rule = "${format("FROM all vms TO tag \"triton.cns.services\" = \"%s\" ALLOW tcp PORT 8080",
            var.cns_service_tag)}"

  depends_on = [
    "triton_machine.mod",
  ]
}

resource "triton_firewall_rule" "firewall_allow_ingress_8200" {
  count = "${var.firewall_enabled ? 1 : 0}"

  enabled = true

  description = "${format("Allow TCP/8200 to Vault - %s",
                   var.instance_name_prefix)}"

  rule = "${format("FROM any TO tag \"triton.cns.services\" = \"%s\" ALLOW tcp PORT 8200",
            var.cns_service_tag)}"

  depends_on = [
    "triton_machine.mod",
  ]
}

resource "triton_firewall_rule" "firewall_allow_ingress_8201" {
  count = "${var.firewall_enabled ? 1 : 0}"

  enabled = true

  description = "${format("Allow TCP/8201 to Vault nodes only - %s",
                   var.instance_name_prefix)}"

  rule = "${format("FROM tag \"triton.cns.services\" = \"%s\" TO tag \"triton.cns.services\" = \"%s\" ALLOW tcp PORT 8201",
            var.cns_service_tag, var.cns_service_tag)}"

  depends_on = [
    "triton_machine.mod",
  ]
}

resource "triton_firewall_rule" "firewall_allow_ingress_8301" {
  count = "${var.firewall_enabled ? 1 : 0}"

  enabled = true

  description = "${format("Allow TCP/8301 to Vault - %s",
                   var.instance_name_prefix)}"

  rule = "${format("FROM any TO tag \"triton.cns.services\" = \"%s\" ALLOW tcp PORT 8301",
            var.cns_service_tag)}"

  depends_on = [
    "triton_machine.mod",
  ]
}
