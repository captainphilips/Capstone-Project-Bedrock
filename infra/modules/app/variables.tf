variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the retail app"
  type        = string
  default     = "retail-app"
}

variable "catalog_db_endpoint" {
  description = "Catalog database endpoint"
  type        = string
}

variable "catalog_db_port" {
  description = "Catalog database port"
  type        = number
}

variable "orders_db_endpoint" {
  description = "Orders database endpoint"
  type        = string
}

variable "orders_db_port" {
  description = "Orders database port"
  type        = number
}
