output "environment" {
  value = "${map(var.environment,
             data.external.mod.result.environment)}"
}
