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

data "aws_caller_identity" "this" {
  provider = aws.this
}

data "aws_caller_identity" "that" {
  provider = aws.that
}

locals {
  arn_iam_role_format = "arn:aws:iam::%s:role/%s"
}

locals {
  this_projectname = "sfn-alpha"
  that_projectname = "codebuild-beta"

  this_account_id = data.aws_caller_identity.this.account_id
  that_account_id = data.aws_caller_identity.that.account_id

  this_arn_iam_role = format(local.arn_iam_role_format, local.this_account_id, local.this_projectname)

  that_iam_role_name_codebuild_starter = "${local.that_projectname}-cb-starter"
  that_iam_role_arn_codebuild_starter  = format(local.arn_iam_role_format, local.that_account_id, local.that_iam_role_name_codebuild_starter)
}


module "this" {
  providers = {
    aws = aws.this
  }

  source                              = "./this"
  projectname                         = local.this_projectname
  arn_iam_role_name_codebuild_starter = local.that_iam_role_arn_codebuild_starter
}

module "that" {
  providers = {
    aws = aws.that
  }

  source                          = "./that"
  projectname                     = local.that_projectname
  arn_iam_role_parent             = local.this_arn_iam_role
  iam_role_name_codebuild_starter = local.that_iam_role_name_codebuild_starter
}
