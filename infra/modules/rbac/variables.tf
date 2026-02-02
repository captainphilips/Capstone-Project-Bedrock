############################
# RBAC Module Variables
############################
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
