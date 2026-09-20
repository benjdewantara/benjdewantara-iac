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

module "this" {
  source = "./this"

  providers = {
    aws = aws.this
  }

  projectname = "s3-this-parent1"
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

  projectname      = "cb-that"
  s3_bucket_parent = module.this.s3_bucketname
}
