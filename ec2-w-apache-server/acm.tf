#module "cert" {
#  source             = "./cert"
#  region             = "us-east-1"
#  domain_name_public = local.domain_name_public
#}

module "cert_us_east_1" {
  source             = "./cert"
  region             = "us-east-1"
  domain_name_public = local.domain_name_public
}

module "cert_ap_southeast_1" {
  source             = "./cert"
  region             = "ap-southeast-1"
  domain_name_public = local.domain_name_public

#  lifecycle {
#    create_before_destroy = true
#  }
}

resource "time_sleep" "delay_cert_ap_southeast_1" {
  depends_on = [module.cert_ap_southeast_1]

  create_duration = "30s"
}


#resource "aws_acm_certificate" "this" {
#  domain_name       = local.domain_name_public
#  validation_method = "DNS"
#
#  tags = {
#    iacpath = "benj-apache-wkwk/acm.tf"
#  }
#
#  #  lifecycle {
#  #    create_before_destroy = true
#  #  }
#}
#
#resource "aws_acm_certificate_validation" "this" {
#  certificate_arn = aws_acm_certificate.this.arn
#  #  validation_record_fqdns = aws_acm_certificate.this.domain_validation_options
#}
#
#resource "aws_route53_record" "example" {
#  for_each = {
#    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
#      name   = dvo.resource_record_name
#      record = dvo.resource_record_value
#      type   = dvo.resource_record_type
#    }
#  }
#
#  allow_overwrite = true
#  name            = each.value.name
#  records         = [each.value.record]
#  ttl             = 60
#  type            = each.value.type
#  zone_id         = local.route53zoneid
#}
#
##resource "aws_route53_record" "this_www" {
##  zone_id = local.route53zoneid
##  name    = aws_acm_certificate_validation
##  type    = "CNAME"
##  ttl     = 300
##  records = [aws_lb.this.dns_name]
##}
