############################
# EKS Module Variables
############################
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "barakat-2025-capstone-bedrock-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.34"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for worker nodes"
  type        = list(string)
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs for worker nodes (compat alias)"
  type        = list(string)
  default     = null
  validation {
    condition     = var.subnet_ids != null || var.private_subnet_ids != null
    error_message = "Provide subnet_ids or private_subnet_ids."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
