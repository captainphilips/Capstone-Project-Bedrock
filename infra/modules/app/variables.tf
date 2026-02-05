############################
# APP Module Variables
############################
variable "cluster_name" {
  description = "EKS cluster name"
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
