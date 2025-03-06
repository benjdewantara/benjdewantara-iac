terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

provider "aws" {
  profile = "benj"
  region  = "us-east-1"
}

locals {
  role_name = "${var.nickname}"
}

resource "aws_iam_role" "this" {
  name = local.role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "codepipeline.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  name = "inline-${local.role_name}"
  role = aws_iam_role.this.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "codecommit:*",
            "s3:*",
            "kms:*"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}