############################
# Variables
############################
variable "cluster_endpoint" {
  description = "EKS cluster endpoint (set once EKS is created)."
  type        = string
  default     = ""
}
