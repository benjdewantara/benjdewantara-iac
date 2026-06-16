# module "cert_us_east_1" {
#   source = "../acm-cert-region-specific"
#
#   domain        = local.app_domain
#   region        = "us-east-1"
#   route53zoneid = var.zone_id
# }

module "cert_ap_southeast_1" {
  source = "../acm-cert-region-specific"

  domain        = local.app_domain
  region        = "ap-southeast-1"
  route53zoneid = var.zone_id
}
