############################
# APP Module Outputs
############################
output "app_namespace" {
  description = "Kubernetes namespace for retail app"
  value       = var.app_namespace
}

output "app_deployed" {
  description = "Whether app is deployed"
  value       = false
}
