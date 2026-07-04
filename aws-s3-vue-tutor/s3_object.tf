locals {
  content_type_map = {
    html = "text/html"
    css  = "text/css"
    js   = "text/javascript"
    ico  = "image/vnd.microsoft.icon"
  }
}

locals {
  root_dir  = var.root_dir
  filenames = fileset(local.root_dir, "**")

  file_upload_specs = [for f in local.filenames : {
    pathabs      = join("/", [local.root_dir, f])
    content_type = lookup(local.content_type_map, element(split(".", f), -1), "application/octet-stream")
    key          = f
    }
  ]
}

resource "aws_s3_object" "files" {
  for_each = zipmap(
    [for o in local.file_upload_specs : o.key],
    [for o in local.file_upload_specs : o]
  )

  bucket       = aws_s3_bucket.this.bucket
  key          = each.value["key"]
  source       = each.value["pathabs"]
  etag         = filemd5(each.value["pathabs"])
  content_type = each.value["content_type"]
}
