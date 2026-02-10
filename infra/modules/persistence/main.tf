terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_db_subnet_group" "this" {
  name       = "project-bedrock-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Project = "barakat-2025-capstone"
    }
  )
}

resource "aws_security_group" "db" {
  name        = "project-bedrock-db-sg"
  description = "Allow database access from within the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Project = "barakat-2025-capstone"
    }
  )
}

resource "random_password" "catalog" {
  length  = 20
  special = true
}

resource "random_password" "orders" {
  length  = 20
  special = true
}

resource "aws_db_instance" "catalog" {
  identifier              = "project-bedrock-catalog"
  engine                  = "mysql"
  instance_class          = var.mysql_instance_class
  allocated_storage       = 20
  db_name                 = "catalog"
  username                = "catalog"
  password                = random_password.catalog.result
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = 7
  apply_immediately       = true
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = merge(
    var.tags,
    {
      Project = "barakat-2025-capstone"
    }
  )
}

resource "aws_db_instance" "orders" {
  identifier              = "project-bedrock-orders"
  engine                  = "postgres"
  instance_class          = var.postgres_instance_class
  allocated_storage       = 20
  db_name                 = "orders"
  username                = "orders"
  password                = random_password.orders.result
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = 7
  apply_immediately       = true
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = merge(
    var.tags,
    {
      Project = "barakat-2025-capstone"
    }
  )
}

resource "aws_secretsmanager_secret" "catalog" {
  name = "project-bedrock/catalog-db"

  tags = merge(
    var.tags,
    {
      Project = "barakat-2025-capstone"
    }
  )
}

resource "aws_secretsmanager_secret" "orders" {
  name = "project-bedrock/orders-db"

  tags = merge(
    var.tags,
    {
      Project = "barakat-2025-capstone"
    }
  )
}

resource "aws_secretsmanager_secret_version" "catalog" {
  secret_id = aws_secretsmanager_secret.catalog.id
  secret_string = jsonencode({
    username = aws_db_instance.catalog.username
    password = random_password.catalog.result
    endpoint = aws_db_instance.catalog.address
    port     = aws_db_instance.catalog.port
    database = aws_db_instance.catalog.db_name
  })
}

resource "aws_secretsmanager_secret_version" "orders" {
  secret_id = aws_secretsmanager_secret.orders.id
  secret_string = jsonencode({
    username = aws_db_instance.orders.username
    password = random_password.orders.result
    endpoint = aws_db_instance.orders.address
    port     = aws_db_instance.orders.port
    database = aws_db_instance.orders.db_name
  })
}
############################
# Persistence Module - RDS MySQL/Postgres + Secrets
############################
variable "environment" {
  description = "Environment name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for database security group"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for database access"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "mysql_db_name" {
  description = "Catalog database name"
  type        = string
  default     = "catalog"
}

variable "postgres_db_name" {
  description = "Orders database name"
  type        = string
  default     = "orders"
}

variable "mysql_username" {
  description = "Catalog database username"
  type        = string
  default     = "catalog"
}

variable "postgres_username" {
  description = "Orders database username"
  type        = string
  default     = "orders"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

resource "random_password" "mysql" {
  length  = 20
  special = true
}

resource "random_password" "postgres" {
  length  = 20
  special = true
}

resource "aws_db_subnet_group" "this" {
  name       = "bedrock-${var.environment}-db-subnets"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "db" {
  name        = "bedrock-${var.environment}-db-sg"
  description = "Database access for ${var.environment}"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL access from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "PostgreSQL access from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_db_instance" "mysql" {
  identifier              = "bedrock-${var.environment}-catalog"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  allocated_storage       = var.allocated_storage
  storage_type            = "gp3"
  storage_encrypted       = true
  username                = var.mysql_username
  password                = random_password.mysql.result
  db_name                 = var.mysql_db_name
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  publicly_accessible     = false
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = true
  apply_immediately       = true

  tags = var.tags
}

resource "aws_db_instance" "postgres" {
  identifier              = "bedrock-${var.environment}-orders"
  engine                  = "postgres"
  engine_version          = "16.1"
  instance_class          = var.db_instance_class
  allocated_storage       = var.allocated_storage
  storage_type            = "gp3"
  storage_encrypted       = true
  username                = var.postgres_username
  password                = random_password.postgres.result
  db_name                 = var.postgres_db_name
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  publicly_accessible     = false
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = true
  apply_immediately       = true

  tags = var.tags
}

resource "aws_secretsmanager_secret" "mysql" {
  name = "bedrock/${var.environment}/catalog-db"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({
    username = var.mysql_username
    password = random_password.mysql.result
    host     = aws_db_instance.mysql.address
    port     = aws_db_instance.mysql.port
    dbname   = var.mysql_db_name
    engine   = "mysql"
  })
}

resource "aws_secretsmanager_secret" "postgres" {
  name = "bedrock/${var.environment}/orders-db"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id
  secret_string = jsonencode({
    username = var.postgres_username
    password = random_password.postgres.result
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    dbname   = var.postgres_db_name
    engine   = "postgres"
  })
}

output "mysql_endpoint" {
  description = "MySQL endpoint"
  value       = aws_db_instance.mysql.address
}

output "mysql_port" {
  description = "MySQL port"
  value       = aws_db_instance.mysql.port
}

output "mysql_secret_arn" {
  description = "MySQL secret ARN"
  value       = aws_secretsmanager_secret.mysql.arn
}

output "postgres_endpoint" {
  description = "PostgreSQL endpoint"
  value       = aws_db_instance.postgres.address
}

output "postgres_port" {
  description = "PostgreSQL port"
  value       = aws_db_instance.postgres.port
}

output "postgres_secret_arn" {
  description = "Postgres secret ARN"
  value       = aws_secretsmanager_secret.postgres.arn
}
