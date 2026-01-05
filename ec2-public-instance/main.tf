provider "aws" {
  profile = "benj"
  region  = "ap-southeast-1"
}

data "aws_availability_zones" "available" {}

locals {
  projectname = "pubsimple"

  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  cidr_vpc     = "10.0.0.0/24"
  cidrs_subnet = [for k, v in range(2 * length(local.azs)) : cidrsubnet(local.cidr_vpc, 3, k)]
  create_vpc   = true

  s3_bucket_name = local.projectname
}
