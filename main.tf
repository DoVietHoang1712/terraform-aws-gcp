locals {
  project_name = "terraform-aws"
}

data "vault_aws_access_credentials" "creds" {
  backend = "aws"
  role    = "Admin-role"
}

provider "aws" {
  region     = "us-east-1"
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}

# module "vpc" {
#   source   = "./modules/networking"
#   project  = local.project_name
#   vpc_cidr = var.vpc_cidr
#   subnets  = var.aws_subnets
#   vpc_name = var.vpc_name
# }

# module "aws-vpm-gcp" {
#   source         = "./modules/vpn"
#   vpc_id         = module.vpc.vpc.id
#   aws_cidr_block = module.vpc.vpc.cidr_block
#   region         = var.gcp_region
#   account_id     = var.account_id
#   subnet_id      = module.vpc.public_subnet
#   ig_id          = module.vpc.igw
# }
