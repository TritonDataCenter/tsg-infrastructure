data "external" "mod" {
  program = [
    "bash",
    "${path.module}/scripts/environment.sh",
  ]

  query = {
    name = "${var.name}"
  }
}
