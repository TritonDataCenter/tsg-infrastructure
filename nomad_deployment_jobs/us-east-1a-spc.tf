variable "job_name" {
  default = "tsg-v1"
}

variable "dc" {
  default = "us-east-1a"
}

variable "triton_url" {
  default = "https://us-east-1a.api.samsungcloud.io"
}

variable "triton_auth_url" {
  default = "https://us-east-1a.api.samsungcloud.io"
}

variable "auth_whitelist" {
  default = "true"
}

variable "crdb_user" {
  default = "root"
}

variable "crdb_database" {
  default = "triton"
}

variable "crdb_cns" {
  default = "cockroach.svc.svctsgstg.us-east-1a.cns.scloud.host"
}

variable "nomad_cns" {
  default = "nomad-server.svc.svctsgstg.us-east-1a.cns.scloud.host"
}

variable "nomad_port" {
  default = "4646"
}

variable "api_version" {
  default = "v1"
}

variable "api_release_version" {
  default = "0.2.9"
}
