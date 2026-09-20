variable "projectname" { type = string }

data "aws_caller_identity" "this" {}

resource "aws_s3_bucket" "this" {
  bucket = var.projectname
}

output "s3_bucketname" {
  value = aws_s3_bucket.this.bucket
}