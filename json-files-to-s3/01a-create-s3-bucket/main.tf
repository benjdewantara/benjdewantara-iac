resource "random_string" "this" {
  length    = 8
  lower     = true
  min_lower = 8
  special   = false
}

locals {
  bucket_name = "bucket-bnj-${random_string.this.result}"
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
}

output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}
