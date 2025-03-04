terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
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

  validation {
    condition     = length(var.nickname)>0
    error_message = "You must provide nickname"
  }
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

output "output_bucket_name" {
  value = aws_s3_bucket.this.bucket
}