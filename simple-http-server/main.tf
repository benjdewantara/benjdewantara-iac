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
    value = aws_vpc.main.id
}