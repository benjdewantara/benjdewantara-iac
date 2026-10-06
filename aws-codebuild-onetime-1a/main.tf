variable "aws_profile_this" { type = string }
variable "projectname" { type = string }

provider "aws" {
  profile = var.aws_profile_this
}

data "aws_caller_identity" "this" {}

locals {
}

resource "aws_iam_role" "this" {
  name = "${var.projectname}-cb"

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
            "codebuild.amazonaws.com"
          ]
        }
      }
    ]
    }
  )

  tags = {
    iacpath = "aws-codebuild-onetime-1a/main.tf"
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

data "template_file" "that" {
  template = file("./buildspec.yml")

  vars = {
  }
}

resource "aws_codebuild_project" "this" {
  name         = var.projectname
  service_role = aws_iam_role.this.arn

  source {
    type      = "NO_SOURCE"
    buildspec = data.template_file.that.rendered
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    # host_kernel     = "LINUX_KERNEL_6"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  tags = {
    iacpath = "aws-codebuild-onetime-1a/main.tf"
  }
}
