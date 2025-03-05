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
  iam_role_codepipeline_individual_app = "iamr-${var.system_nickname}-codepipeline"
}

resource "aws_iam_role" "codepipeline_individual_app" {
  name = local.iam_role_codepipeline_individual_app

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