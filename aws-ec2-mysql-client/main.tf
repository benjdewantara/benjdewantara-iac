variable "aws_profile_this" { type = string }
variable "cidr_block" { type = string }
variable "projectname" { type = string }

provider "aws" {
  profile = var.aws_profile_this
  region  = "ap-southeast-1"
}

locals {
  cidr_block_vpc = cidrsubnet(var.cidr_block, 0, 0)

  cidr_subnet_4_0 = cidrsubnet(var.cidr_block, 1, 0)
  cidr_subnet_4_1 = cidrsubnet(var.cidr_block, 1, 1)
  # cidr_subnet_4_2 = cidrsubnet(var.cidr_block, 1, 2)
  # cidr_subnet_4_3 = cidrsubnet(var.cidr_block, 1, 3)
  # cidr_subnet_4_4 = cidrsubnet(var.cidr_block, 1, 4)
}

output "cidr_manual_division" {
  value = {
    cidr_block      = var.cidr_block,
    cidr_block_vpc  = local.cidr_block_vpc,
    cidr_subnet_4_0 = local.cidr_subnet_4_0,
    cidr_subnet_4_1 = local.cidr_subnet_4_1,
    # cidr_subnet_4_2 = local.cidr_subnet_4_2,
    # cidr_subnet_4_3 = local.cidr_subnet_4_3,
    # cidr_subnet_4_4 = local.cidr_subnet_4_4,
  }
}

resource "aws_vpc" "this" {
  cidr_block = local.cidr_block_vpc

  tags = {
    Name    = var.projectname
    iacpath = "aws-ec2-mysql-client/main.tf"
  }
}

resource "aws_subnet" "this_private" {
  vpc_id     = aws_vpc.this.id
  cidr_block = local.cidr_subnet_4_0

  tags = {
    Name    = "${var.projectname}-private"
    iacpath = "aws-ec2-mysql-client/main.tf"
  }
}
