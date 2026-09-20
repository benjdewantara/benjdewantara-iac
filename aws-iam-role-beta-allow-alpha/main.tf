variable "aws_profile_this" { type = string }
variable "aws_profile_that" { type = string }

provider "aws" {
  alias   = "this"
  profile = var.aws_profile_this
}

provider "aws" {
  alias   = "that"
  profile = var.aws_profile_that
}

data "aws_caller_identity" "this" {
  provider = aws.this
}

data "aws_caller_identity" "that" {
  provider = aws.that
}

locals {
  rolename_this = "iamr-this"
  rolename_that = "iamr-that"

  role_arn_format = "arn:aws:iam::%s:role/%s"

  role_arn_this = format(local.role_arn_format, data.aws_caller_identity.this.account_id, local.rolename_this)
  role_arn_that = format(local.role_arn_format, data.aws_caller_identity.that.account_id, local.rolename_that)
}

resource "aws_iam_role" "this" {
  provider = aws.this

  name                 = local.rolename_this
  max_session_duration = 1 * 60 * 60

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "AWS" : [
            data.aws_caller_identity.this.account_id,
            local.role_arn_that,
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role" "that" {
  provider = aws.that

  name                 = local.rolename_that
  max_session_duration = 1 * 60 * 60

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "AWS" : [
            data.aws_caller_identity.this.account_id
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "that" {
  provider = aws.that

  role = aws_iam_role.that.name
  name = "${aws_iam_role.that.name}-inline"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AssumeParent",
          "Effect" : "Allow",
          "Action" : [
            "sts:assumeRole",
          ],
          "Resource" : [
            local.role_arn_this
          ]
        }
      ]
    }
  )
}
