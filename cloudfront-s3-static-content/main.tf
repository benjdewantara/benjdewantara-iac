provider "aws" {
  profile = "benjdewantara2"
  region  = "ap-southeast-3"
}

resource "random_string" "this" {
  length           = 8
  lower            = true
  min_lower        = 8
  special          = false
  override_special = "5fc3ddbb"
}

locals {
  bucketname_random = "benj-${random_string.this.result}"
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucketname_random


  tags = {
    "iacpath" = "cloudfront-s3-static-content/main.tf"
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.bucket
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "StatementAllowFolderTempPublic",
        "Effect": "Allow",
        "Principal": "*",
        "Action": ["s3:GetObject"],
        "Resource": "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
      }
    ]
  }
  EOF
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.this.bucket
  key          = "index.html"
  source       = "./objects_uploaded/index.html"
  content_type = "text/html"
}
