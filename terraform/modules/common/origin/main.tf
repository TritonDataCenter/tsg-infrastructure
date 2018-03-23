data "external" "mod" {
  program = ["bash", "${path.module}/scripts/origin.sh"]

  query = {
    add_cidr = "${var.add_cidr}"
  }
}
