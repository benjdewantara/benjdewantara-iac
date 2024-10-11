resource "aws_cloudfront_distribution" "this" {
  aliases         = [local.domain_name_public, local.domain_name_public_www]
  enabled         = true
  comment         = "cf-${local.friendlyname}"
  is_ipv6_enabled = true
  #  default_root_object = "index.html"

  wait_for_deployment = true

  origin {
    domain_name = aws_lb.this.dns_name
    origin_id   = "alb-${local.friendlyname}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["SSLv3"]
      origin_read_timeout    = 180
    }
  }

  #  origin {
  #    domain_name = data.aws_s3_bucket.bucket_existing.bucket_domain_name
  #    origin_id   = "s3-s3origin"
  #    origin_access_control_id = local.oac_existing
  #  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb-${local.friendlyname}"

    #    forwarded_values {
    #      query_string = false
    #
    #      cookies {
    #        forward = "none"
    #      }
    #    }

    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    #    response_headers_policy_id = ""

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  #  ordered_cache_behavior {
  #    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  #    cached_methods         = ["GET", "HEAD"]
  #    path_pattern           = "*"
  #    target_origin_id       = "s3-s3origin"
  #    viewer_protocol_policy = "allow-all"
  #
  #    forwarded_values {
  #      query_string = false
  #      headers      = ["Origin"]
  #
  #      cookies {
  #        forward = "none"
  #      }
  #    }
  #  }

  #  custom_error_response {
  #    error_code         = 403
  #    response_code      = 403
  #    response_page_path = "/error-pages/benj-error.html"
  #  }

  #  custom_error_response {
  #    error_code         = 502
  #    response_code      = 502
  #    response_page_path = "/error-pages/benj-error.html"
  #  }

  viewer_certificate {
    acm_certificate_arn = module.cert_us_east_1.acm_this.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ... other configuration ...
}
