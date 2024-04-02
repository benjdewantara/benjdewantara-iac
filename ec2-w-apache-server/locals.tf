locals {
  route53zoneid = "SAMPLESAMPLESAMPLESAMPLE"

  domain_name_public     = "benj1.example.com"
  domain_name_public_www = "www.${local.domain_name_public}"

  email_certbot = "benj1@example.com"

  friendlyname = "benj-apache-wkwk"
  #  aws_cf_domain_name_1 = aws_lb.this.dns_name

  bucket_existing = ""
  oac_existing    = ""
}
