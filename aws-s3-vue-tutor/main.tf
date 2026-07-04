provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucketname
}

locals {
  root_dir  = var.root_dir
  filenames = fileset(local.root_dir, "**")

  file_upload_specs = [for f in local.filenames : {
    pathabs = join("/", [local.root_dir, f])
    key     = f
    }
  ]
}

resource "aws_s3_object" "files" {
  for_each = zipmap(
    [for o in local.file_upload_specs : o.key],
    [for o in local.file_upload_specs : o]
  )

  bucket = aws_s3_bucket.this.bucket
  key    = each.value["key"]
  source = each.value["pathabs"]
  etag   = filemd5(each.value["pathabs"])
}
