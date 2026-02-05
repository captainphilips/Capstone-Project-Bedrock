terraform {
  backend "s3" {
    bucket         = "project-bedrock-0347-tf-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "project-bedrock-tf-lock"
    encrypt        = true
  }
}
