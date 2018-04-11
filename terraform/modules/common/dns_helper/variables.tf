variable "public_domain" {
  type = "map"

  default = {
    jpc = "joyent.zone"
    spc = "samsungcloud.zone"
  }
}
