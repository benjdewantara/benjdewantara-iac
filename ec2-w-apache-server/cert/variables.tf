variable "region" {
  description = "AWS region in which the ACM certificate is created"
  type        = string
  default     = "us-east-1"
}

variable "domain_name_public" {
  description = "Domain name for Route 53 record"
  type        = string
}