locals {
  domain_stripped = startswith(var.domain, "www.") ? trimprefix(var.domain, "www.") : var.domain
  domain_wildcard = "*.${local.domain_stripped}"
}

data "aws_route53_zone" "this" {
  zone_id = var.route53zoneid
}
