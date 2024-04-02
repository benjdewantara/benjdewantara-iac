resource "aws_route53_record" "this" {
  zone_id = local.route53zoneid
  name    = local.domain_name_public
  type    = "CNAME"
  ttl     = 300
  #  records = [aws_lb.this.dns_name]
  records = [aws_cloudfront_distribution.this.domain_name]
}

resource "aws_route53_record" "this_www" {
  zone_id = local.route53zoneid
  name    = local.domain_name_public_www
  type    = "CNAME"
  ttl     = 300
  #  records = [aws_lb.this.dns_name]
  records = [aws_cloudfront_distribution.this.domain_name]
}
