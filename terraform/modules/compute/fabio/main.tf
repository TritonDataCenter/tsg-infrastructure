provider "cloudflare" {}

locals {
  public_cns_domain = "${format("%s.%s", var.cns_service_tag,
                         var.public_cns_fragment)}"

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
  }
}

resource "null_resource" "depends_on" {
  triggers {
    depends_on = "${join("", flatten(var.depends_on))}"
  }
}

resource "triton_machine" "mod" {
  count = "${var.instance_count}"

  name    = "${format("%s-fabio-%02d", var.instance_name_prefix, count.index + 1)}"
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
    "${format("instance!=~%s-fabio-*", var.instance_name_prefix)}",
  ]

  cns {
    services = [
      "${var.cns_service_tag}",
    ]
  }

  metadata = "${var.metadata}"

  tags = "${merge(map(
    "name", "${format("%s-fabio-%02d", var.instance_name_prefix, count.index + 1)}"
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

resource "null_resource" "mod" {
  count = "${var.instance_count}"

  triggers {
    fabio_instance_ids = "${join(",", triton_machine.mod.*.id)}"
  }

  connection {
    type         = "ssh"
    user         = "ubuntu"
    host         = "${element(triton_machine.mod.*.primaryip, count.index)}"
    bastion_host = "${var.bastion_cns_url}"
    timeout      = "120s"
  }

  provisioner "file" {
    content = <<EOF
export MANTA_URL='${coalesce(module.manta_url.value, module.manta_helper.manta_url)}'
export MANTA_USER='${module.triton_account.value}'
export MANTA_KEY_ID='${module.triton_key_id.value}'
EOF

    destination = "/var/tmp/.manta"
  }

  provisioner "file" {
    content = "${format("export MANTA_PATH='~~/stor/certificates/%s/%s'",
                         var.cloud, data.triton_datacenter.mod.name)}"

    destination = "/var/tmp/.certificate"
  }

  provisioner "remote-exec" {
    scripts = [
      "${format("%s/files/%s", path.module, "configure.sh")}",
      "${format("%s/files/%s", path.module, "start.sh")}",
    ]
  }
}

resource "cloudflare_record" "mod" {
  count = "${var.instance_count}"

  domain = "${var.cloudflare_domain}"
  name   = "${var.cloudflare_name}"

  type  = "A"
  value = "${element(triton_machine.mod.*.primaryip, count.index)}"
  ttl   = "${var.cloudflare_ttl}"
}

resource "triton_firewall_rule" "firewall_allow_ingress_ssh" {
  count = "${var.firewall_enabled ? length(var.firewall_targets_list) : 0}"

  enabled = true

  description = "${format("Allow SSH to Fabio from %s - %s",
                   element(var.firewall_targets_list, count.index),
                   var.instance_name_prefix)}"

  rule = "${format("FROM %s TO tag \"triton.cns.services\" = \"%s\" ALLOW tcp PORT 22",
            element(var.firewall_targets_list, count.index), var.cns_service_tag)}"

  depends_on = [
    "triton_machine.mod",
  ]
}

resource "triton_firewall_rule" "firewall_allow_ingress_https" {
  count = "${var.firewall_enabled ? 1 : 0}"

  enabled = true

  description = "${format("Allow HTTPS to Fabio - %s",
                   var.instance_name_prefix)}"

  rule = "${format("FROM any TO tag \"triton.cns.services\" = \"%s\" ALLOW tcp PORT 443",
            var.cns_service_tag)}"

  depends_on = [
    "triton_machine.mod",
  ]
}

resource "triton_firewall_rule" "firewall_allow_ingress_9998" {
  count = "${var.firewall_enabled ? 1 : 0}"

  enabled = true

  description = "${format("Allow TCP/9998 to Fabio - %s",
                   var.instance_name_prefix)}"

  rule = "${format("FROM all vms TO tag \"triton.cns.services\" = \"%s\" ALLOW tcp PORT 9998",
            var.cns_service_tag)}"

  depends_on = [
    "triton_machine.mod",
  ]
}
