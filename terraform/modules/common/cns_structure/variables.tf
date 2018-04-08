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
