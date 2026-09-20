data "aws_caller_identity" "that" {}

locals {
  arn_codebuild_format = "arn:aws:codebuild::%s:%s"
  arn_codebuild        = format(local.arn_codebuild_format, data.aws_caller_identity.that.account_id, "*")
}

data "local_file" "that" {
  filename = "./buildspec.yml"
}

resource "aws_iam_role" "that" {
  name = "iamr-that"

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

resource "aws_iam_role_policy" "that" {
  role = aws_iam_role.that.name
  name = "CodeBuildCanCloudWatch-inline"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "CodeBuildCanCloudWatch",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_codebuild_project" "that" {
  name         = "cb-that"
  service_role = aws_iam_role.that.arn

  source {
    type      = "NO_SOURCE"
    buildspec = data.local_file.that.content
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }
}
