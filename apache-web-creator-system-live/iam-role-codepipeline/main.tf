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

module "this" {
  source = "../../apache-web-creator-system/communal/iam-role"

  nickname = "awcs-codepipeline"

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

  policy_inline_json = jsonencode(
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