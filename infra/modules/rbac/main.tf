############################
# RBAC Module - ClusterRoleBinding & Roles
############################
# Manages Kubernetes RBAC for developer access and service accounts

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "developer_username" {
  description = "Developer IAM username"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Placeholder: implement ClusterRoleBinding and view roles
output "rbac_configured" {
  description = "Whether RBAC is configured"
  value       = false
}
