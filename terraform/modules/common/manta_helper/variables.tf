variable "manta_public_domain" {
  type = "map"

  default = {
    jpc = "joyent.com"
    spc = "samsungcloud.io"
  }
}
