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

variable "use_existing_bedrock_dev_view_user" {
  description = "Set to true if bedrock-dev-view IAM user already exists (e.g. from partial apply)"
  type        = bool
  default     = false
}
