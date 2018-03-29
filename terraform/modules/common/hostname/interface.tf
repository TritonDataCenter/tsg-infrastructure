variable "instance_name_prefix" {
  type = "string"
}

variable "instance_type" {
  type = "string"
}

variable "instance_count" {
  default = 1
}

variable "cloud_config" {
  default = []
}

variable "cloud_init_user_data" {
  default = []
}
