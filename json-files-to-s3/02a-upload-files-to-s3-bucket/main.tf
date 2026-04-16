terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.36.0"
    }
  }
}
variable "s3_bucket" {
  type        = string
  description = "S3 bucket to upload files to"
}

data "aws_s3_bucket" "this" {
  bucket = var.s3_bucket
}

resource "aws_s3_object" "this" {
  bucket  = data.aws_s3_bucket.this.bucket
  key     = "something.txt"
  content = "something"
}
