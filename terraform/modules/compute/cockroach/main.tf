locals {
  private_cns_domain = "${format("%s.svc.%s.%s.cns.joyent.com", var.cns_service_tag,
                          data.triton_account.mod.id, data.triton_datacenter.mod.name)}"
}

data "triton_account" "mod" {}

data "triton_datacenter" "mod" {}

resource "triton_machine" "mod" {
  count = "${var.instances_count}"

  name    = "${format("%s-cockroach-%02d", var.name-prefix, count.index + 1)}"
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
    "${format("instance!=~/^%s-cockroach-\\d+/", var.name-prefix)}"
  ]

  cns {
    services = [
      "${var.cns_service_tag}"
    ]
  }

  metadata = "${var.metadata}"

  tags = "${merge(map(
      "name", "${format("%s-cockroach-%02d", var.name-prefix, count.index + 1)}"
    ), var.tags)}"
}

resource "random_shuffle" "mod" {
  input = [
    "${triton_machine.mod.*.primaryip}"
  ]

  result_count = 1
}

resource "null_resource" "mod" {
  count = "${var.instances_count}"

  triggers {
    cockroach_instance_ids = "${join(",", triton_machine.mod.*.id)}"
  }

  connection {
    type         = "ssh"
    user         = "ubuntu"
    host         = "${element(triton_machine.mod.*.primaryip, count.index)}"
    bastion_host = "${var.bastion_host}"
    timeout      = "120s"
  }

  provisioner "file" {
    content = <<EOF
NODES='${join(",", sort(flatten(triton_machine.mod.*.ips)))}'
INSECURE='${var.insecure ? "true" : "false"}'
LEADER='${element(random_shuffle.mod.result, 0)}'
EOF

    destination = "/var/tmp/.cockroach-cluster"
  }

  provisioner "remote-exec" {
    scripts = [
      "${format("%s/files/%s", path.module, "volume.sh")}",
      "${format("%s/files/%s", path.module, "configure.sh")}",
      "${format("%s/files/%s", path.module, "start.sh")}",
    ]
  }
}
