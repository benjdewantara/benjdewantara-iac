terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

provider "aws" {
  profile = "benj"
  region  = "ap-southeast-3"
}
locals {
  codecommit_repo_name = "cc-${var.nickname}"
}

resource "aws_codecommit_repository" "this" {
  repository_name = local.codecommit_repo_name
}