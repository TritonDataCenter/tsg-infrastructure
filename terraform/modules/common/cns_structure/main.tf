data "triton_account" "mod" {}

data "triton_datacenter" "mod" {}

locals {
  public_cns_fragment = "${format("svc.%s.%s.%s", data.triton_account.mod.id,
                           data.triton_datacenter.mod.name, var.public_dns[var.cloud])}"

  private_cns_fragment = "${format("svc.%s.%s.cns.%s", data.triton_account.mod.id,
                            data.triton_datacenter.mod.name, var.private_dns[var.cloud])}"
}
