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
  this_projectname = "s3-this-parent1"
  that_projectname = "cb-that"

  this_account_id = data.aws_caller_identity.this.account_id
  that_account_id = data.aws_caller_identity.that.account_id

  arn_iam_role_format = "arn:aws:iam::%s:role/%s"
  this_arn_iam_role   = format(local.arn_iam_role_format, local.this_account_id, local.this_projectname)
}

module "this" {
  source = "./this"

  providers = {
    aws = aws.this
  }

  projectname     = local.this_projectname
  account_id_user = local.that_account_id
  iam_role_user   = local.that_projectname
}

output "this_s3_bucketname" {
  value = module.this.s3_bucketname
}

resource "time_sleep" "this_delay" {
  depends_on      = [module.this]
  create_duration = "10s"
}

module "that" {
  depends_on = [module.this, time_sleep.this_delay]

  source = "./that"

  providers = {
    aws = aws.that
  }

  projectname         = local.that_projectname
  s3_bucket_parent    = module.this.s3_bucketname
  arn_iam_role_parent = local.this_arn_iam_role
}
