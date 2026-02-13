terraform {
  backend "s3" {
    bucket         = "barakat-2025-capstone-tf-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "barakat-2025-capstone-tf-lock"
    encrypt        = true
  }
}
