############################
# Observability Module - CloudWatch, Logging, Metrics
############################
# Manages CloudWatch log groups, EKS add-ons, and monitoring

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Placeholder: implement CloudWatch log groups and EKS add-ons
output "log_group_name" {
  description = "CloudWatch log group for EKS"
  value       = ""
}
