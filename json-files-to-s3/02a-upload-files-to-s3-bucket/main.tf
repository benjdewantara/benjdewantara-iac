variable "s3_bucket" {
  type        = string
  description = "S3 bucket to upload files to"
}

data "aws_s3_bucket" "this" {
  bucket = var.s3_bucket
}

locals {
  fileset_to_upload = fileset("${path.module}/../../sample_files_to_upload", "**")

  a26 = {
    hell = "worl"
  }
}

resource "aws_s3_object" "this" {
  for_each = local.fileset_to_upload
  # for_each = toset([])

  bucket       = data.aws_s3_bucket.this.bucket
  content_type = "text/plain"
  key          = "${basename("${path.module}/../../sample_files_to_upload")}/${each.value}"
  source       = "${"${path.module}/../../sample_files_to_upload"}/${each.value}"
  etag         = filemd5("${"${path.module}/../../sample_files_to_upload"}/${each.value}")
}

output "filepaths" {
  value = local.fileset_to_upload
}
