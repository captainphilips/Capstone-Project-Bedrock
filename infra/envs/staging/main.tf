############################
# staging Environment - Root Module
############################
module "vpc" {
  source = "../../modules/vpc"

  azs  = local.azs
  tags = local.tags
}
