provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  index_document {
    suffix = "index.html"
  }
}

# resource "aws_s3_bucket_public_access_block" "this" {
#   bucket = aws_s3_bucket.this.bucket
#
#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.bucket
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : [
            "s3:GetObject"
          ],
          "Resource" : [
            "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
          ]
        }
      ]
    }
  )
}
