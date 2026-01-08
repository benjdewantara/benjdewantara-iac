data "aws_route53_zone" "this" {
  zone_id = local.zone_id
}

output "a1" {
  value = "app-${random_string.this.result}.${data.aws_route53_zone.this.name}"
}

# resource "aws_route53_record" "this" {
#   name    = "app-${random_string.this.result}.${data.aws_route53_zone.this.name}"
#   type    = "CNAME"
#   zone_id = data.aws_route53_zone.this.zone_id
#   ttl     = 300
#   records = [module.ec2_this[0].public_dns]
# }
