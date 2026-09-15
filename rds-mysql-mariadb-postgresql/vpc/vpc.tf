provider "aws" {
  profile = var.aws_profile
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.projectname
  }
}
