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

locals {
  ec2_instance_name = "${local.projectname}-${random_string.this.result}"
  time_now          = timestamp()
}

# this recreates resource random_string each time `terraform apply` occurs
resource "random_string" "this" {
  keepers = { marker = local.time_now }

  length    = 4
  lower     = true
  min_lower = 4
  special   = false
}
