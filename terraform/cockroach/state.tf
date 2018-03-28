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

data "terraform_remote_state" "networking" {
  backend = "manta"

  config {
    path = "tsg-networking"
  }
}