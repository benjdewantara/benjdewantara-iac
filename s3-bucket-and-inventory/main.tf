terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}


resource "aws_s3_bucket" "bucket_w_invtry" {
  bucket = "bucket-with-inventory"
}

resource "aws_s3_bucket" "bucket_w_invtry_output" {
  bucket = "bucket-with-inventory-output"
}

resource "aws_s3_bucket_inventory" "invtry_orc" {
  bucket = aws_s3_bucket.bucket_w_invtry.id
  name   = "EntireBucketDailyORC"

  included_object_versions = "All"

  schedule {
    frequency = "Daily"
  }

  destination {
    bucket {
      format     = "ORC"
      bucket_arn = aws_s3_bucket.bucket_w_invtry_output.arn
    }
  }
}

resource "aws_s3_bucket_inventory" "invtry_parquet" {
  bucket = aws_s3_bucket.bucket_w_invtry.id
  name   = "EntireBucketDailyParquet"

  included_object_versions = "All"

  schedule {
    frequency = "Daily"
  }

  destination {
    bucket {
      format     = "Parquet"
      bucket_arn = aws_s3_bucket.bucket_w_invtry_output.arn
    }
  }
}