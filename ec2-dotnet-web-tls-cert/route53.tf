data "aws_route53_zone" "this" {
  name = local.route53_hosted_zone_name
}

resource "aws_route53_record" "this_www" {
  zone_id = data.aws_route53_zone.this.id
  name    = local.app_live_domain
  type    = "CNAME"
  ttl     = 300
  #  records = [aws_lb.this.dns_name]
  #  records = [aws_cloudfront_distribution.this.domain_name]
  records = [aws_instance.this.public_dns]
}