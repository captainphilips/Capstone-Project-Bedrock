############################
# EKS Module Outputs
############################
output "cluster_name" {
  description = "EKS cluster name"
  value       = ""
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = ""
}

output "cluster_ca_certificate" {
  description = "Base64 encoded cluster CA certificate"
  value       = ""
}

output "oidc_provider_arn" {
  description = "ARN of OIDC provider for IRSA"
  value       = ""
}
