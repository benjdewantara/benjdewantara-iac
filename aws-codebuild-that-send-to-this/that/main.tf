variable "projectname" { type = string }
variable "s3_bucket_parent" { type = string }
variable "arn_iam_role_parent" { type = string }

data "aws_caller_identity" "that" {}

locals {
  arn_codebuild_format = "arn:aws:codebuild::%s:%s"
  arn_codebuild        = format(local.arn_codebuild_format, data.aws_caller_identity.that.account_id, "*")

  s3_uri_parent = "s3://${var.s3_bucket_parent}"
}

resource "aws_iam_role" "that" {
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
          "AWS" : [
            data.aws_caller_identity.that.account_id,
          ],
          "Service" : [
            "codebuild.amazonaws.com"
          ]
        }
      }
    ]
    }
  )
}

resource "aws_iam_role_policy" "that1" {
  role = aws_iam_role.that.name
  name = "CloudWatch-inline"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "CloudWatch",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            # "logs:DescribeLogGroups",
            # "logs:DescribeLogStreams",
            "logs:PutLogEvents",
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "that2" {
  role = aws_iam_role.that.name
  name = "STS-inline"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "STS",
          "Effect" : "Allow",
          "Action" : [
            "sts:AssumeRole",
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

data "template_file" "that" {
  template = file("./buildspec.yml")

  vars = {
    S3_URI_PARENT = local.s3_uri_parent
    ARN_IAM_ROLE_PARENT = var.arn_iam_role_parent
  }
}

resource "aws_codebuild_project" "that" {
  name         = var.projectname
  service_role = aws_iam_role.that.arn

  source {
    type      = "NO_SOURCE"
    buildspec = data.template_file.that.rendered
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:8.0"
    # host_kernel     = "LINUX_KERNEL_6"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }
}
