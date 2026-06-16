provider "aws" {
  region  = var.region
}

resource "aws_acm_certificate" "this" {
  domain_name       = local.domain_wildcard
  validation_method = "DNS"

  subject_alternative_names = [
    local.domain_wildcard,
    local.domain_stripped
  ]

  tags = {
    iacpath = "acm-cert-region-specific/acm.tf"
  }
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.id
}