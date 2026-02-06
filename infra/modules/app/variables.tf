variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the retail app"
  type        = string
  default     = "retail-app"
}
