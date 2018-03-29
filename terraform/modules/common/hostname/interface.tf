variable "name_prefix" {}
variable "instance_type" {}

variable "instance_count" {
  default = 1
}

variable "cloud_config" {
  default = []
}

variable "cloud_init_user_data" {
  default = []
}