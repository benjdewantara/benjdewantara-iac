terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.36.0"
    }
  }
}
variable "aws_profile_this" { type = string }
variable "aws_profile_that" { type = string }

provider "aws" {
  alias   = "this"
  profile = var.aws_profile_this
  region  = "ap-southeast-1"
}

provider "aws" {
  alias   = "that"
  profile = var.aws_profile_that
  region  = "ap-southeast-1"
}

locals {
  this_projectname = "sfn-alpha"
  that_projectname = "codebuild-beta"
}

module "this" {
  providers = {
    aws = aws.this
  }

  source      = "./this"
  projectname = local.this_projectname
}

module "that" {
  providers = {
    aws = aws.that
  }

  source      = "./that"
  projectname = local.that_projectname
}
