terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

variable "base_cidr_block" {
  description = "A /24 CIDR range definition, such as 122.110.81.0/24, that the VPC will use"
  default     = "122.110.81.0/24"
}

resource "aws_vpc" "main_vpc" {
  # Referencing the base_cidr_block variable allows the network address
  # to be changed without modifying the configuration.
  cidr_block = var.base_cidr_block

  tags = {
    "Name" = "Simple VPC"
  }
}

output "main_vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.main_vpc.id
}


resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
}

output "main_igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main_igw.id
}


resource "aws_route_table" "main_rtb" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    "Name" = "simpleHttpServerRtb"
  }
}

resource "aws_subnet" "main_subnet" {
  cidr_block = aws_vpc.main_vpc.cidr_block
  vpc_id     = aws_vpc.main_vpc.id
  tags = {
    "Name" = "simpleHttpServerSubnet"
  }
}

resource "aws_security_group" "main_secgroup" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "simpleHttpServerSg"
}

output "main_secgroup_id" {
  description = "The Security Group ID"
  value       = aws_security_group.main_secgroup.id

}

resource "aws_instance" "main_ec2_instance" {
  ami                    = "ami-02f26adf094f51167"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.main_secgroup.id]
  subnet_id              = aws_subnet.main_subnet.id

  tags = {
    Name = "SimpleHTTPServer"
  }
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main_ec2_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main_ec2_instance.public_ip
}
