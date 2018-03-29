data "template_file" "mod" {
  count = "${var.instance_count}"

  template = "${file(format("%s/templates/%s", path.module, "cloud-config.tpl"))}"

  vars {
    hostname = "${format("%s-%s-%02d", var.instance_name_prefix,
                  var.instance_type, count.index + 1)}"
  }
}

data "template_cloudinit_config" "mod" {
  count = "${var.instance_count}"

  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.cfg"
    content_type = "text/cloud-config"

    content = "${element(coalescelist(var.cloud_config,
                 data.template_file.mod.*.rendered),
                 count.index)}"
  }

  part {
    filename     = "cloud_init_user_data.sh"
    content_type = "text/x-shellscript"

    content = "${length(var.cloud_init_user_data) > 0 ?
                 element(concat(var.cloud_init_user_data, list("")),
                 count.index) : ""}"
  }
}
