provider "aws" {
  profile = "benj"
  region  = var.region
}

resource "aws_acm_certificate" "this" {
  domain_name       = local.domain_name_public_wildcard
  validation_method = "DNS"

  subject_alternative_names = [
    local.domain_name_public_wildcard,
    local.domain_name_public_www_stripped
  ]

  tags = {
    iacpath = "ec2-w-apache-server/cert/acm.tf"
  }

  #  lifecycle {
  #    create_before_destroy = true
  #  }
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
  zone_id         = local.route53zoneid
}