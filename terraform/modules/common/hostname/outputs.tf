output "rendered" {
  value = [
    "${data.template_cloudinit_config.mod.*.rendered}",
  ]
}
