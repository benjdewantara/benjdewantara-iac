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

resource "aws_vpc" "main" {
  # Referencing the base_cidr_block variable allows the network address
  # to be changed without modifying the configuration.
  cidr_block = var.base_cidr_block

  tags = {
    "Name" = "Simple VPC"
  }
}

output "aws_vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.main.id
}


resource "aws_subnet" "main_subnet" {
  cidr_block = aws_vpc.main.cidr_block
  vpc_id     = aws_vpc.main.id
  tags = {
    "Name" = "simpleHttpServerSubnet"
  }
}

output "main_subnet_id" {

}

resource "aws_security_group" "main_secgroup" {
  vpc_id = aws_vpc.main.id
  name   = "simpleHttpServerSg"
}

output "main_secgroup_id" {
  description = "The Security Group ID"
  value       = aws_security_group.main_secgroup.id
}

resource "aws_instance" "instance_simple_http_server" {
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
  value       = aws_instance.instance_simple_http_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.instance_simple_http_server.public_ip
}
