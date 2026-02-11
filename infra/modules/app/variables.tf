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

variable "catalog_db_username" {
  description = "Catalog database username"
  type        = string
  default     = "catalog"
  sensitive   = true
}

variable "catalog_db_password" {
  description = "Catalog database password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "orders_db_endpoint" {
  description = "Orders database endpoint"
  type        = string
}

variable "orders_db_port" {
  description = "Orders database port"
  type        = number
}

variable "orders_db_name" {
  description = "Orders database name"
  type        = string
  default     = "orders"
}

variable "orders_db_username" {
  description = "Orders database username"
  type        = string
  default     = "orders"
  sensitive   = true
}

variable "orders_db_password" {
  description = "Orders database password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "catalog_db_port" {
  description = "Catalog database port"
  type        = number
}
