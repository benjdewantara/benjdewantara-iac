provider "aws" {
  profile = "benj"
  region  = "ap-southeast-3"
}

data "aws_region" "current" {}

locals {
  friendlyname = "ec2-w-letsencrypt-certbot"
}

resource "aws_vpc" "this" {
  cidr_block                       = "122.110.0.0/16"
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "vpc-${local.friendlyname}"
    iacpath = "ec2-w-letsencrypt-certbot/main.tf"
  }
}

resource "aws_subnet" "aza_apps" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}a"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 0)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 0)

  tags = {
    Name    = "subnet-aza-apps"
    iacpath = "ec2-w-letsencrypt-certbot/main.tf"
  }
}

resource "aws_subnet" "aza_web" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}a"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 1)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 1)

  map_public_ip_on_launch = true

  tags = {
    Name    = "subnet-aza-web"
    iacpath = "ec2-w-letsencrypt-certbot/main.tf"
  }
}

resource "aws_subnet" "azb_apps" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}b"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 2)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 2)


  tags = {
    Name    = "subnet-azb-apps"
    iacpath = "ec2-w-letsencrypt-certbot/main.tf"
  }
}

resource "aws_subnet" "azb_web" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}b"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 3)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 3)

  map_public_ip_on_launch = true

  tags = {
    Name    = "subnet-azb-web"
    iacpath = "ec2-w-letsencrypt-certbot/main.tf"
  }
}

resource "aws_subnet" "azc_apps" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}c"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 4)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 4)


  tags = {
    Name    = "subnet-azc-apps"
    iacpath = "ec2-w-letsencrypt-certbot/main.tf"
  }
}

resource "aws_subnet" "azc_web" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}c"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 5)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 5)

  map_public_ip_on_launch = true

  tags = {
    Name    = "subnet-azc-web"
    iacpath = "ec2-w-letsencrypt-certbot/main.tf"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "igw-${local.friendlyname}"
    iacpath = "ec2-w-letsencrypt-certbot/main.tf"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name    = "rtb-benj"
    iacpath = "ec2-w-letsencrypt-certbot/main.tf"
  }
}

resource "aws_route_table_association" "rtb_assoc_web_1" {
  subnet_id      = aws_subnet.aza_web.id
  route_table_id = aws_route_table.this.id
}

resource "aws_route_table_association" "rtb_assoc_web_2" {
  subnet_id      = aws_subnet.azb_web.id
  route_table_id = aws_route_table.this.id
}

resource "aws_route_table_association" "rtb_assoc_web_3" {
  subnet_id      = aws_subnet.azc_web.id
  route_table_id = aws_route_table.this.id
}

# resource "aws_route_table_association" "rtb_assoc_bpps_1" {
# subnet_id      = aws_subnet.aza_apps.id
# route_table_id = aws_route_table.this.id
# }

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

resource "aws_security_group" "this" {
  vpc_id      = aws_vpc.this.id
  name        = "secgroup-${local.friendlyname}"
  description = "This is security group benj_web"

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow outgoing packets"
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
  }

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow incoming packets"
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
  }
}

resource "aws_iam_role" "this" {
  name = "iamr-${local.friendlyname}"

  inline_policy {
    name = "iampolicy_inline_iamrole_benj_web"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : "s3:*",
          "Resource" : "*"
        }
      ]
    })
  }

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
  name = "iamip-${local.friendlyname}"
  role = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon-linux-2.image_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.aza_web.id
  security_groups             = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  key_name                    = var.ec2_keypair_name

  user_data = file("./user_data.sh")

  tags = {
    Name    = "ec2-${local.friendlyname}"
    iacpath = "ec2-w-letsencrypt-certbot/main.tf"
  }
}

