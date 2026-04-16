variable "s3_bucket" {
  type        = string
  description = "S3 bucket to upload files to"
}

data "aws_s3_bucket" "this" {
  bucket = var.s3_bucket
}

resource "aws_s3_object" "this" {
  for_each = fileset("${path.module}/files_template", "*")

  bucket       = data.aws_s3_bucket.this.bucket
  content_type = "text/plain"
  key          = "files_template/${each.key}"
  source       = "${path.module}/files_template/${each.key}"
}

locals {
  f = fileset("${path.module}/files_template", "*")

  a26 = {
    hell = "worl"
  }
}

output "filepaths" {
  value = local.a26
}
