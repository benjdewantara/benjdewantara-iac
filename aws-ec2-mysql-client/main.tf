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

resource "aws_subnet" "this_public" {
  vpc_id     = aws_vpc.this.id
  cidr_block = local.cidr_subnet_4_1

  tags = {
    Name    = "${var.projectname}-public"
    iacpath = "aws-ec2-mysql-client/main.tf"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "${var.projectname}-public"
    iacpath = "aws-ec2-mysql-client/main.tf"
  }
}

resource "aws_route_table" "this_public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name    = "${var.projectname}-public"
    iacpath = "aws-ec2-mysql-client/main.tf"
  }
}

resource "aws_route_table_association" "this_public" {
  route_table_id = aws_route_table.this_public.id
  subnet_id      = aws_subnet.this_public.id
}

resource "aws_security_group" "this_public" {
  name   = "${var.projectname}-public"
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "${var.projectname}-public"
    iacpath = "aws-ec2-mysql-client/main.tf"
  }
}

resource "aws_vpc_security_group_ingress_rule" "this_public" {
  security_group_id = aws_security_group.this_public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*"]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.this_public.id
  associate_public_ip_address = true

  tags = {
    Name    = var.projectname
    iacpath = "aws-ec2-mysql-client/main.tf"
  }
}
