terraform {
  backend "manta" {
    path = "tsg-bastion"
  }
}

data "terraform_remote_state" "networking" {
  backend = "manta"

  config {
    path = "tsg-networking"
  }
}