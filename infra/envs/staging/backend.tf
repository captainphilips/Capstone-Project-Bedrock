terraform {
  backend "s3" {
    bucket         = "project-bedrock-0347-tf-state"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}
