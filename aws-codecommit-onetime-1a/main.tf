variable "aws_profile_this" { type = string }
variable "aws_region" { type = string }
variable "repository_names" { type = string }

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile_this
}

resource "aws_codecommit_repository" "this" {
  for_each = toset(var.repository_names)

  repository_name = each.value

  tags = {
    iacpath = "aws-codecommit-onetime-1a/main.tf"
  }
}
