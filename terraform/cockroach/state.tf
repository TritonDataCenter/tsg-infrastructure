terraform {
  backend "manta" {
    path = "tsg-cockroach"
  }
}

data "terraform_remote_state" "bastion" {
  backend = "manta"

  config {
    path = "tsg-bastion"
  }
}
