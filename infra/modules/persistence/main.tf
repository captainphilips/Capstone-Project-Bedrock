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
      Project = "Bedrock-Terraform"
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
      Project = "Bedrock-Terraform"
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
  multi_az                = var.multi_az

  tags = merge(
    var.tags,
    {
      Project = "Bedrock-Terraform"
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
  multi_az                = var.multi_az

  tags = merge(
    var.tags,
    {
      Project = "Bedrock-Terraform"
    }
  )
}

resource "aws_secretsmanager_secret" "catalog" {
  name = "project-bedrock/catalog-db"

  tags = merge(
    var.tags,
    {
      Project = "Bedrock-Terraform"
    }
  )
}

resource "aws_secretsmanager_secret" "orders" {
  name = "project-bedrock/orders-db"

  tags = merge(
    var.tags,
    {
      Project = "Bedrock-Terraform"
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
