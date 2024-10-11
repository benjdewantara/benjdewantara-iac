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
  content_type = "text/html"

  content = <<EOF
  <html>
      <body>
          <h1>This is benj test html for S3 bucket ${aws_s3_bucket.this.bucket} generated at ${timestamp()}</h1>
      </body>
  </html>
  EOF
}

locals {
  s3originid = "OriginId-${aws_s3_bucket.this.bucket}"
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "example"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  default_root_object = "index.html"
  enabled             = true

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_id                = local.s3originid
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3originid
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    "iacpath" = "cloudfront-s3-static-content/main.tf"
  }
}
