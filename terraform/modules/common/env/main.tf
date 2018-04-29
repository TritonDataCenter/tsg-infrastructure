data "external" "mod" {
  program = [
    "bash",
    "${path.module}/scripts/environment.sh",
  ]

  query = {
    name              = "${var.name}"
    allow_empty_value = "${var.allow_empty_value}"
  }
}
