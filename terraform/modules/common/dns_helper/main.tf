data "triton_datacenter" "mod" {}

locals {
  domain_name = "${var.public_domain[var.cloud]}"

  fqdn = "${format("tsg.%s.svc.%s", data.triton_datacenter.mod.name,
            var.public_domain[var.cloud])}"
}
