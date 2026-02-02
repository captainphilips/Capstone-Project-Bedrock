############################
# RDS Module (Optional/Bonus)
############################
# Manages MySQL and PostgreSQL databases

variable "engine_type" {
  description = "Database engine: mysql or postgres"
  type        = string
  default     = "postgres"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Placeholder: implement RDS instances
output "database_endpoint" {
  description = "RDS database endpoint"
  value       = ""
}
