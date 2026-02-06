############################
# RBAC Module Variables
############################
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider" {
  description = "OIDC provider ARN (compat alias)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "assets_bucket_name" {
  description = "Assets bucket name for upload access"
  type        = string
}
