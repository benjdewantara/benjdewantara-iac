variable "aws_profile" { type = string }
variable "projectname" { type = string }
variable "rds_engine" { type = string }
variable "rds_engine_version" { type = string }
variable "region" { type = string }

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

# module "vpc" {
#   source = "../vpc"
#
#   aws_profile = var.aws_profile
#   aws_region  = "ap-southeast-1"
#   projectname = var.projectname
#   vpc_cidr    = "10.0.0.0/24"
# }

data "aws_availability_zones" "available" {
  region = "ap-southeast-1"
}

locals {
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  cidr_vpc     = "10.0.0.0/24"
  cidrs_subnet = [for k, v in range(2 * length(local.azs)) : cidrsubnet(local.cidr_vpc, 3, k)]
}

module "vpc" {
  source     = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
  create_vpc = true

  name = var.projectname
  cidr = "10.0.0.0/24"

  azs = local.azs
  # intra_subnets  = [for i in range(0, 0 + 3) : local.cidrs_subnet[i]]
  # private_subnets = [for i in range(0, 0 + 3) : local.cidrs_subnet[i]]
  public_subnets = [for i in range(3, 3 + 3) : local.cidrs_subnet[i]]

  create_igw = true

  manage_default_security_group = false

  tags = {
    iacpath = "tst2/main.tf"
  }
}

module "rds" {
  source = "../rds-single"

  aws_profile        = var.aws_profile
  aws_region         = "ap-southeast-1"
  projectname        = var.projectname
  rds_engine         = var.rds_engine
  rds_engine_version = var.rds_engine_version
  vpc_id             = module.vpc.vpc_id
}
