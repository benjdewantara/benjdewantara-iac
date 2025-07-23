data "aws_region" "current" {}

resource "aws_vpc" "this" {
  cidr_block                       = "192.168.0.0/24"
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "vpc-${local.friendlyname}"
    iacpath = "ec2-lambda-al2023-python3-12/main.tf"
  }
}


resource "aws_subnet" "aza_apps" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}a"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 0)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 0)

  tags = {
    Name    = "subnet-aza-app-${local.friendlyname}"
    iacpath = "ec2-lambda-al2023-python3-12/main.tf"
  }
}

resource "aws_subnet" "aza_web" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}a"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 1)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 1)

  map_public_ip_on_launch = true

  tags = {
    Name    = "subnet-aza-web-${local.friendlyname}"
    iacpath = "ec2-lambda-al2023-python3-12/main.tf"
  }
}

resource "aws_subnet" "azb_apps" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}b"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 2)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 2)


  tags = {
    Name    = "subnet-azb-app-${local.friendlyname}"
    iacpath = "ec2-lambda-al2023-python3-12/main.tf"
  }
}

resource "aws_subnet" "azb_web" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}b"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 3)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 3)

  map_public_ip_on_launch = true

  tags = {
    Name    = "subnet-azb-web-${local.friendlyname}"
    iacpath = "ec2-lambda-al2023-python3-12/main.tf"
  }
}

resource "aws_subnet" "azc_apps" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}c"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 4)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 4)


  tags = {
    Name    = "subnet-azc-app-${local.friendlyname}"
    iacpath = "ec2-lambda-al2023-python3-12/main.tf"
  }
}

resource "aws_subnet" "azc_web" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "${data.aws_region.current.name}c"
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 5)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 5)

  map_public_ip_on_launch = true

  tags = {
    Name    = "subnet-azc-web-${local.friendlyname}"
    iacpath = "ec2-lambda-al2023-python3-12/main.tf"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "igw-${local.friendlyname}"
    iacpath = "ec2-lambda-al2023-python3-12/main.tf"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name    = "rtb-${local.friendlyname}"
    iacpath = "ec2-lambda-al2023-python3-12/main.tf"
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

resource "aws_security_group" "this" {
  vpc_id      = aws_vpc.this.id
  name        = "secgroup-${local.friendlyname}"
  description = "This is security group ${local.friendlyname}"

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
