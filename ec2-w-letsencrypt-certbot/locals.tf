locals {
  route53zoneid = "blank"

  domain_name_public     = "blank.com"
  domain_name_public_www = "www.${local.domain_name_public}"

  email_certbot = "blank"

  friendlyname = "blank"

  s3_bucket_cert_upload = "s3://blank"
}
