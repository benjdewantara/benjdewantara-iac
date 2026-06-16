locals {
  route53zoneid = var.route53zoneid

  domain_name_public     = var.domain_name_public
  domain_name_public_www = "www.${local.domain_name_public}"

  email_certbot = var.email_certbot

  friendlyname = var.friendlyname

  s3_bucket_cert_upload = var.s3_bucket_cert_upload
  s3_bucket_region      = var.s3_bucket_region
}
