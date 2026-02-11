output "catalog_db_endpoint" {
  value = aws_db_instance.catalog.address
}

output "catalog_db_port" {
  value = aws_db_instance.catalog.port
}

output "catalog_db_name" {
  value = aws_db_instance.catalog.db_name
}

output "catalog_db_username" {
  value     = aws_db_instance.catalog.username
  sensitive = true
}

output "catalog_db_password" {
  value     = random_password.catalog.result
  sensitive = true
}

output "catalog_db_secret_arn" {
  value = aws_secretsmanager_secret.catalog.arn
}

output "orders_db_endpoint" {
  value = aws_db_instance.orders.address
}

output "orders_db_port" {
  value = aws_db_instance.orders.port
}

output "orders_db_name" {
  value = aws_db_instance.orders.db_name
}

output "orders_db_username" {
  value     = aws_db_instance.orders.username
  sensitive = true
}

output "orders_db_password" {
  value     = random_password.orders.result
  sensitive = true
}

output "orders_db_secret_arn" {
  value = aws_secretsmanager_secret.orders.arn
}

# Aliases for external_secrets and dev root compatibility
output "mysql_endpoint" {
  value = aws_db_instance.catalog.address
}

output "mysql_port" {
  value = aws_db_instance.catalog.port
}

output "mysql_secret_arn" {
  value = aws_secretsmanager_secret.catalog.arn
}

output "postgres_endpoint" {
  value = aws_db_instance.orders.address
}

output "postgres_port" {
  value = aws_db_instance.orders.port
}

output "postgres_secret_arn" {
  value = aws_secretsmanager_secret.orders.arn
}
