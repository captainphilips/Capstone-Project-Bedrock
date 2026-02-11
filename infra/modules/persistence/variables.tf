variable "environment" {
  description = "Environment name for resource naming"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID for database networking"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for database access"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "mysql_instance_class" {
  description = "Instance class for MySQL"
  type        = string
  default     = "db.t3.micro"
}

variable "postgres_instance_class" {
  description = "Instance class for PostgreSQL"
  type        = string
  default     = "db.t3.micro"
}
