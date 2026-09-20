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

resource "aws_iam_role" "this" {
  provider = aws.this

  name                 = "iamr-source"
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
