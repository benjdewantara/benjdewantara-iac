#output "document_rendered" {
#  value = data.template_file.user_data_ec2_instance.rendered
#}

#output "aws_acm_certificate_this" {
#  sensitive = true
#  value     = aws_acm_certificate.this.
#}

#output "aws_lb_this_dns_name" {
#  value = aws_lb.this.dns_name
#}

#output "aws_lb_this_dns_name_split" {
#  value = element(split(".", aws_lb.this.dns_name), 0)
#}

#output "aws_lb_this_id" {
#  value = aws_lb.this.id
#}

#output "aws_lb_this_name" {
#  value = aws_lb.this.name
#}

#output "bucket_existing" {
#  value = data.aws_s3_bucket.bucket_existing.bucket_domain_name
#}