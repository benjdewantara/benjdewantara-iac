provider "aws" {
  profile = "benjdewantara2"
  region  = "ap-southeast-3"
}

resource "random_uuid" "this" {
}

locals {
  bucketname_random = "benj-${random_uuid.this.result}"
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucketname_random

  tags = {
    "iacpath" = "cloudfront-s3-static-content/main.tf"
  }
}
