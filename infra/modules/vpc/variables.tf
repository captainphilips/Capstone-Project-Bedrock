############################
# VPC Module Variables
############################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "tags" {
  description = "Tags to apply to VPC resources"
  type        = map(string)
  default     = {}
}

variable "cluster_tag" {
  description = "EKS cluster name for subnet discovery tags"
  type        = string
  default     = "barakat-2025-capstone-bedrock-cluster"
}
