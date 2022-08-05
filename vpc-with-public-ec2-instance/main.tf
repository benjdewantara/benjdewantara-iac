provider "aws" {
  profile = "iamadmin-benj-cantrill-management"
  region  = "us-east-1"
}

resource "aws_vpc" "vpc_horbo" {
  cidr_block       = "122.110.0.0/16"
  instance_tenancy = "default"

  tags = {
    "Name" = "vpc-horbo"
  }
}

resource "aws_subnet" "subnet_aza_horbo_apps" {
  vpc_id            = aws_vpc.vpc_horbo.id
  cidr_block        = "122.110.0.0/19"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-aza-horbo-apps"
  }
}

resource "aws_subnet" "subnet_aza_horbo_web" {
  vpc_id                  = aws_vpc.vpc_horbo.id
  cidr_block              = "122.110.32.0/19"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-aza-horbo-web"
  }
}

resource "aws_subnet" "subnet_azb_horbo_apps" {
  vpc_id            = aws_vpc.vpc_horbo.id
  cidr_block        = "122.110.64.0/19"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-azb-horbo-apps"
  }
}

resource "aws_subnet" "subnet_azb_horbo_web" {
  vpc_id                  = aws_vpc.vpc_horbo.id
  cidr_block              = "122.110.96.0/19"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-azb-horbo-web"
  }
}

resource "aws_subnet" "subnet_azc_horbo_apps" {
  vpc_id            = aws_vpc.vpc_horbo.id
  cidr_block        = "122.110.128.0/19"
  availability_zone = "us-east-1c"

  tags = {
    Name = "subnet-azc-horbo-apps"
  }
}

resource "aws_subnet" "subnet_azc_horbo_web" {
  vpc_id                  = aws_vpc.vpc_horbo.id
  cidr_block              = "122.110.160.0/19"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-azc-horbo-web"
  }
}

resource "aws_internet_gateway" "igw_horbo" {
  vpc_id = aws_vpc.vpc_horbo.id

  tags = {
    Name = "igw-horbo"
  }
}

resource "aws_route_table" "rtb_horbo" {
  vpc_id = aws_vpc.vpc_horbo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_horbo.id
  }

  tags = {
    Name = "rtb-horbo"
  }
}

resource "aws_route_table_association" "rtb_assoc_horbo_web_1" {
  subnet_id      = aws_subnet.subnet_aza_horbo_web.id
  route_table_id = aws_route_table.rtb_horbo.id
}

resource "aws_route_table_association" "rtb_assoc_horbo_web_2" {
  subnet_id      = aws_subnet.subnet_azb_horbo_web.id
  route_table_id = aws_route_table.rtb_horbo.id
}

resource "aws_route_table_association" "rtb_assoc_horbo_web_3" {
  subnet_id      = aws_subnet.subnet_azc_horbo_web.id
  route_table_id = aws_route_table.rtb_horbo.id
}

# resource "aws_route_table_association" "rtb_assoc_horbo_apps_1" {
# subnet_id      = aws_subnet.subnet_aza_horbo_apps.id
# route_table_id = aws_route_table.rtb_horbo.id
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

resource "aws_security_group" "secgroup_horbo_web" {
  vpc_id      = aws_vpc.vpc_horbo.id
  name        = "secgroup_horbo_web"
  description = "This is security group secgroup_horbo_web"

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

resource "aws_iam_role" "iamrole_horbo_web" {
  name = "iamrole_horbo_web"

  inline_policy {
    name = "iampolicy_inline_iamrole_horbo_web"
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

resource "aws_iam_instance_profile" "iaminstanceprofile_horbo_web" {
  name = "iaminstanceprofile_horbo_web"
  role = aws_iam_role.iamrole_horbo_web.name
}

resource "aws_instance" "ec2_instance_horbo_web" {
  ami                         = data.aws_ami.amazon-linux-2.image_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet_aza_horbo_web.id
  security_groups             = [aws_security_group.secgroup_horbo_web.id]
  iam_instance_profile        = aws_iam_instance_profile.iaminstanceprofile_horbo_web.name


  tags = {
    Name = "ec2_instance_horbo_web"
  }
}

