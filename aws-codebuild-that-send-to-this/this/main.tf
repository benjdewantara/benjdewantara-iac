variable "projectname" { type = string }
variable "account_id_user" { type = string }
variable "iam_role_user" { type = string }

data "aws_caller_identity" "this" {}

locals {
  arn_iam_role_format = "arn:aws:iam::%s:role/%s"
  user_arn_iam_role   = format(local.arn_iam_role_format, var.account_id_user, var.iam_role_user)
}

resource "aws_iam_role" "this" {
  name                 = var.projectname
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
            local.user_arn_iam_role
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  name = "${aws_iam_role.this.name}-AllowS3"
  role = aws_iam_role.this.name

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowS3",
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
          ],
          "Resource" : "*"
        },
      ]
    }
  )
}

resource "aws_s3_bucket" "this" {
  bucket = var.projectname
}

output "s3_bucketname" {
  value = aws_s3_bucket.this.bucket
}
