variable "accounts_external" { type = list(string) }
variable "aws_profile_this" { type = string }
variable "projectname" { type = string }

provider "aws" {
  profile = var.aws_profile_this
}

data "aws_caller_identity" "this" {}

locals {
  aws_principals_allowed = concat(var.accounts_external, [data.aws_caller_identity.this.account_id])
}

resource "aws_iam_role" "this" {
  name = var.projectname

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "AWS" : local.aws_principals_allowed,
        }
      }
    ]
    }
  )

  tags = {
    iacpath = "aws-iam-role-onetime-1a/main.tf"
  }
}

resource "aws_iam_role_policy" "this" {
  role = aws_iam_role.this.name

  name = "S3"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "S3",
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}
