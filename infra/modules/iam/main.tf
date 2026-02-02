############################
# IAM Module - Developer User & Roles
############################
# Manages IAM user for developers and AWS auth mappings

variable "developer_username" {
  description = "IAM username for developer"
  type        = string
  default     = "bedrock-dev-view"
}

variable "cluster_name" {
  description = "EKS cluster name for auth mapping"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Placeholder: implement developer IAM user and RBAC mappings
output "developer_username" {
  description = "Developer IAM username"
  value       = var.developer_username
}

output "developer_arn" {
  description = "Developer IAM user ARN"
  value       = ""
}
