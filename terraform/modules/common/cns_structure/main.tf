data "triton_account" "mod" {}

data "triton_datacenter" "mod" {}

variable "cloud" {
  default = "jpc"
}

locals {
  public_cns_fragment = "${format("svc.%s.%s.%s", data.triton_account.mod.id, data.triton_datacenter.mod.name, var.public_dns[var.cloud])}"

  private_cns_fragment = "${format("svc.%s.%s.cns.%s", data.triton_account.mod.id, data.triton_datacenter.mod.name, var.private_dns[var.cloud])}"
}

variable "public_dns" {
  type = "map"

  default = {
    jpc = "triton.zone"
    spc = "scloud.zone"
  }
}

variable "private_dns" {
  type = "map"

  default = {
    jpc = "joyent.com"
    spc = "scloud.host"
  }
}

output "public_dns_fragment" {
  value = "${local.public_cns_fragment}"
}

output "private_dns_fragment" {
  value = "${local.private_cns_fragment}"
}