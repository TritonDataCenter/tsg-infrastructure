data "external" "mod" {
  program = [
    "bash",
    "${path.module}/scripts/environment.sh",
  ]

  query = {
    environment = "${var.environment}"
  }
}
