variable "aws_profile" { type = string }
variable "projectname" { type = string }
variable "region" { type = string }

resource "aws_s3_bucket" "this" {
  bucket = var.projectname

  tags = {
    iacpath = "lambda-s3-sns-eventbridge/s3/main.tf"
  }
}

output "bucketname" {
  value = aws_s3_bucket.this.bucket
}
