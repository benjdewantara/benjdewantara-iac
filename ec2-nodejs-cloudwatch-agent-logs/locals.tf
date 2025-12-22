provider "aws" {
  profile = "benj"
  region  = "ap-southeast-1"
}

locals {
  friendlyname                = "bnj-ec2-nodejs-cloudwatch-agent-logs"
  s3_uri_dump_results         = ""
  s3_uri_dump_results_trimmed = trim(local.s3_uri_dump_results, "/")
  iacpath_parent              = "ec2-nodejs-cloudwatch-agent-logs"
}
