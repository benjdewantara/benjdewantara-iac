variable "aws_profile_this" { type = string }
variable "names_bucket" { type = list(string) }

provider "aws" {
  profile = var.aws_profile_this
  region  = "ap-southeast-1"
}

resource "aws_s3_bucket" "this" {
  for_each = toset(var.names_bucket)

  bucket = each.value

  tags = {
    iacpath = "aws-s3-onetime-1a/main.tf"
  }
}
