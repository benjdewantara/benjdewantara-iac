provider "aws" {
  profile = "iamadmin-benj-cantrill-management"
  region  = "us-east-1"
}

resource "aws_vpc" "benj" {
  cidr_block       = "122.110.0.0/16"
  instance_tenancy = "default"

  tags = {
    "Name" = "vpc-benj"
  }
}

resource "aws_subnet" "aza_benj_apps" {
  vpc_id            = aws_vpc.benj.id
  cidr_block        = "122.110.0.0/19"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-aza-benj-apps"
  }
}

resource "aws_subnet" "aza_benj_web" {
  vpc_id                  = aws_vpc.benj.id
  cidr_block              = "122.110.32.0/19"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-aza-benj-web"
  }
}

resource "aws_subnet" "azb_benj_apps" {
  vpc_id            = aws_vpc.benj.id
  cidr_block        = "122.110.64.0/19"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-azb-benj-apps"
  }
}

resource "aws_subnet" "azb_benj_web" {
  vpc_id                  = aws_vpc.benj.id
  cidr_block              = "122.110.96.0/19"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-azb-benj-web"
  }
}

resource "aws_subnet" "azc_benj_apps" {
  vpc_id            = aws_vpc.benj.id
  cidr_block        = "122.110.128.0/19"
  availability_zone = "us-east-1c"

  tags = {
    Name = "subnet-azc-benj-apps"
  }
}

resource "aws_subnet" "azc_benj_web" {
  vpc_id                  = aws_vpc.benj.id
  cidr_block              = "122.110.160.0/19"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-azc-benj-web"
  }
}

resource "aws_internet_gateway" "igw_benj" {
  vpc_id = aws_vpc.benj.id

  tags = {
    Name = "igw-benj"
  }
}

resource "aws_route_table" "rtb_benj" {
  vpc_id = aws_vpc.benj.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_benj.id
  }

  tags = {
    Name = "rtb-benj"
  }
}

resource "aws_route_table_association" "rtb_assoc_benj_web_1" {
  subnet_id      = aws_subnet.aza_benj_web.id
  route_table_id = aws_route_table.rtb_benj.id
}

resource "aws_route_table_association" "rtb_assoc_benj_web_2" {
  subnet_id      = aws_subnet.azb_benj_web.id
  route_table_id = aws_route_table.rtb_benj.id
}

resource "aws_route_table_association" "rtb_assoc_benj_web_3" {
  subnet_id      = aws_subnet.azc_benj_web.id
  route_table_id = aws_route_table.rtb_benj.id
}

# resource "aws_route_table_association" "rtb_assoc_benj_apps_1" {
# subnet_id      = aws_subnet.aza_benj_apps.id
# route_table_id = aws_route_table.rtb_benj.id
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

resource "aws_security_group" "benj_web" {
  vpc_id      = aws_vpc.benj.id
  name        = "benj_web"
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

resource "aws_iam_role" "benj_web" {
  name = "benj_web"

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

resource "aws_iam_instance_profile" "benj_web" {
  name = "benj_web"
  role = aws_iam_role.benj_web.name
}

resource "aws_instance" "ec2_instance_benj_web" {
  ami                         = data.aws_ami.amazon-linux-2.image_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.aza_benj_web.id
  security_groups             = [aws_security_group.benj_web.id]
  iam_instance_profile        = aws_iam_instance_profile.benj_web.name


  tags = {
    Name = "ec2_instance_benj_web"
  }
}

