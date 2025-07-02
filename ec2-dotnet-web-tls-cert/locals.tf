locals {
  friendlyname              = "dotnet-web-tls-cert"
  git_dotnet_project        = ""
  git_dotnet_project_subdir = ""

  route53_hosted_zone_name = ""

  app_live_domain = ""
  app_url_https   = "https://${local.app_live_domain}"

  s3_uri_cert             = "s3://"
  s3_uri_cert_private_key = "s3://"
  s3_bucket_region_cert   = "ap-northeastsouthwest-99"
}
