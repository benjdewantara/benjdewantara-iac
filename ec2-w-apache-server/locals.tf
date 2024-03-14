locals {
  route53zoneid = "SAMPLESAMPLESAMPLESAMPLE"

  domain_name_public = "benj1.example.com"
  email_certbot      = "benj1@example.com"

  friendlyname         = "benj-apache-wkwk"
  aws_cf_domain_name_1 = aws_lb.this.dns_name
}

