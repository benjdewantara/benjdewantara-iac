terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}
provider "aws" {
  profile = "benj"
  region  = "ap-southeast-3"
}

variable "nickname" {
  default     = ""
  description = "Distinguishing nickname for the set of resources contained within"
  type        = string
}

resource "random_id" "txt_random" {
  byte_length = 8
}

locals {
  name_random        = random_id.txt_random.hex
  bucket_name_random = "benj-${var.nickname}-${local.name_random}"
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name_random
}

output "bucket_name" {
  value = aws_s3_bucket.this.arn
}