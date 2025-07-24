provider "aws" {
  profile = "benj"
  region  = "ap-southeast-1"
}

locals {
  friendlyname        = "bnj-build-lambda-layer"
  s3_uri_dump_results = ""
  s3_uri_dump_results_trimmed = trim(local.s3_uri_dump_results, "/")
}
