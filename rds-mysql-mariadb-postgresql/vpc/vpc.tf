provider "aws" {
  profile = var.aws_profile
}

data "aws_region" "current" {}

resource "aws_vpc" "this" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.projectname
  }
}

# resource "aws_subnet" "this" {
#   vpc_id = aws_vpc.this.id
#
#   availability_zone = "${data.aws_region.current.name}a"
#   cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 1)
# }

# resource "aws_security_group" "this" {
#
# }
