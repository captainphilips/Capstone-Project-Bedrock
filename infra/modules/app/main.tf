############################
# App Module - Kubernetes Deployments & Helm Releases
############################
# Manages retail store application deployment on EKS

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type        = string
}

variable "app_namespace" {
  description = "Kubernetes namespace for retail app"
  type        = string
  default     = "retail-app"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Placeholder: implement Kubernetes namespace and Helm releases for retail app
output "app_namespace" {
  description = "Kubernetes namespace for retail app"
  value       = var.app_namespace
}

output "app_deployed" {
  description = "Whether app is deployed"
  value       = false
}
