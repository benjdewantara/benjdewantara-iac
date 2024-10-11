provider "aws" {
  profile = "default2"
  region  = "ap-southeast-3"
}

data "aws_region" "current" {}

locals {
  quickname = "amznlnx2"
}

resource "aws_vpc" "this" {
  cidr_block                       = "10.6.0.0/24"
  assign_generated_ipv6_cidr_block = true

  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${local.quickname}"
  }
}

resource "aws_subnet" "this" {
  vpc_id = aws_vpc.this.id

  availability_zone = "${data.aws_region.current.name}a"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 0)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 0)

  tags = {
    Name = "sn-pub-aza-${local.quickname}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw-${local.quickname}"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.this.id
  }

  tags = {
    Name = "rtb-public-${local.quickname}"
  }
}

resource "aws_route_table_association" "this" {
  route_table_id = aws_route_table.this.id
  subnet_id      = aws_subnet.this.id
}

data "aws_ami" "amazon-linux-2" {
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
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_ami" "amazon-linux-2023" {
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
    name = "name"
    # values = ["al2023-ami-2023.*"]
    values = ["al2023-ami-minimal-2023.*"]
  }
}

resource "aws_iam_role" "this" {
  name = "iamr-${local.quickname}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "iaminstp-${local.quickname}"
  role = aws_iam_role.this.name
}

resource "aws_security_group" "this" {
  description = "Security group for ${local.quickname}"
  vpc_id      = aws_vpc.this.id
  name        = "secgroup-${local.quickname}"

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow outgoing packets"
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming from all but only port 1994"
    from_port   = 1194
    protocol    = "udp"
    to_port     = 1194
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
}

resource "aws_instance" "this" {
  count = 1

  # ami           = data.aws_ami.amazon-linux-2.image_id
  ami           = data.aws_ami.amazon-linux-2023.image_id
  instance_type = "t3.micro"
  # instance_type                 = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.this.id
  iam_instance_profile        = aws_iam_instance_profile.this.name
  security_groups             = [aws_security_group.this.id]
  key_name                    = var.ec2_keypair_name

  user_data = file("./ec2_instance_user_data.sh")

  tags = {
    Name = "ec2-inst-${local.quickname}"
  }
}