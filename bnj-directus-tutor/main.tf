provider "aws" {
  profile = "benj"
  region  = "ap-southeast-1"
}

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  projectname = "bnj-directus-tutor"

  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  cidr_vpc     = "10.0.0.0/24"
  cidrs_subnet = [for k, v in range(2 * length(local.azs)) : cidrsubnet(local.cidr_vpc, 3, k)]
  create_vpc   = true

  github_pat         = var.github_pat
  uri_app_repository = var.uri_app_repository
  s3_bucket_name     = local.projectname

  zone_id    = var.zone_id
  app_domain = "app-${random_string.this.result}.${data.aws_route53_zone.this.name}"

  ebs_device_name            = "/dev/xvdz"
  ebs_device_name_in_machine = "/dev/nvme1n1"
}

locals {
  ec2_instance_name = "${local.projectname}-${random_string.this.result}"
  time_now          = timestamp()
}

data "aws_region" "current" {}

# this recreates resource random_string each time `terraform apply` occurs
resource "random_string" "this" {
  keepers = { marker = local.time_now }

  length    = 4
  lower     = true
  min_lower = 4
  special   = false
}

output "app_domain" {
  value = aws_route53_record.this.name
}

output "app_domain_http" {
  value = "http://${aws_route53_record.this.name}"
}
