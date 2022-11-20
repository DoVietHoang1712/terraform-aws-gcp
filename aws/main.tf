locals {
  project_name = "terraform-aws"
}

module "vpc" {
  source = "./modules/networking"
  project = local.project_name
  vpc_cidr = "192.168.0.0/16"
  subnets = {
    "private" = ["192.168.1.0/24", "192.168.2.0/24"]
    "public" = ["192.168.3.0/24", "192.168.4.0/24"]
    "zone" = ["us-east-1a", "us-east-1b"]
  }
  vpc_name = "MyVPC"
}

module "aws-vpm-gcp" {
  source = "./modules/vpn"
  vpc_id = module.vpc.vpc.id
  aws_cidr_block = module.vpc.vpc.cidr_block
  region = "us-east1"
  account_id = "hoangdv"
  subnet_id = module.vpc.public_subnet
  ig_id = module.vpc.igw
}