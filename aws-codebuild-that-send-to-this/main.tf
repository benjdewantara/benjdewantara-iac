variable "aws_profile_this" { type = string }
variable "aws_profile_that" { type = string }

provider "aws" {
  alias   = "this"
  profile = var.aws_profile_that
  region  = "ap-southeast-1"
}

provider "aws" {
  alias   = "that"
  profile = var.aws_profile_that
  region  = "ap-southeast-1"
}

module "that" {
  source = "./that"

  providers = {
    aws = aws.that
  }

  projectname = "cb-that"
}

