locals {
  manta_endpoint = "${format("%s.manta.%s", var.datacenter,
                      var.manta_public_domain[var.cloud])}"

  manta_url = "${format("https://%s.manta.%s/", var.datacenter,
                 var.manta_public_domain[var.cloud])}"
}
