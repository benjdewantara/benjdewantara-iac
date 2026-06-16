provider "aws" {
  profile = "benj"
  region  = "ap-southeast-1"
}

data "aws_availability_zones" "available" {}

locals {
  projectname = var.projectname

  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  cidr_vpc     = "10.0.0.0/24"
  cidrs_subnet = [for k, v in range(2 * length(local.azs)) : cidrsubnet(local.cidr_vpc, 3, k)]
  create_vpc   = true

  github_pat         = var.github_pat
  uri_app_repository = "https://${local.github_pat}@github.com/benjdewantara/bnj-golang-gin-tutor.git"
  s3_bucket_name     = local.projectname

  zone_id = var.zone_id
  # app_domain = "app-${random_string.this.result}.${data.aws_route53_zone.this.name}"
  app_domain = "${var.projectname_subdomain}.${data.aws_route53_zone.this.name}"
}

locals {
  ec2_instance_name = "${local.projectname}-${random_string.this.result}"
  time_now          = timestamp()
}

# specs
locals {
  microservice_specs = tomap(var.microservice_specs)
}

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
