locals {
  route53zoneid = "Z10111333ACM4JNU6AJR1"

  domain_name_public_input = var.domain_name_public

  domain_name_public_www_stripped = startswith(local.domain_name_public_input, "www.") ? trimprefix(local.domain_name_public_input, "www.") : local.domain_name_public_input
  domain_name_public_wildcard = startswith(local.domain_name_public_www_stripped, "*.") ? local.domain_name_public_www_stripped : "*.${local.domain_name_public_www_stripped}"

#  domain_name_public_www = "www.${local.domain_name_public_www_stripped}"

  #  friendlyname         = "benj-apache-wkwk"
  #  aws_cf_domain_name_1 = aws_lb.this.dns_name
}
