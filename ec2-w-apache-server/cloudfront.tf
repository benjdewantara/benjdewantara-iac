# resource "aws_cloudfront_distribution" "this" {

#   origin {
#     domain_name = local.aws_cf_domain_name_1
#     origin_id   = "origin-${aws_lb.this.name}"

#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "Some comment"
#   default_root_object = "index.html"

#   aliases = ["mysite.example.com", "yoursite.example.com"]

#   default_cache_behavior {
#     # ... other configuration ...
#     target_origin_id = local.aws_cf_domain_name_1
#   }

#   # ... other configuration ...
# }
