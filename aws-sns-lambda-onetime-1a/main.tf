variable "aws_profile_this" { type = string }
variable "projectname" { type = string }

provider "aws" {
  region  = "ap-southeast-1"
  profile = var.aws_profile_this
}

resource "aws_sns_topic" "this" {
  display_name = "${var.projectname}-display_name"
  name         = "${var.projectname}-name"
}

resource "aws_iam_role" "this" {
  name = "${var.projectname}-lmd"

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
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "local_file" "this" {
  filename = "index.mjs"
  content  = file("${path.module}/../scripts/lambda-print.js")
}

resource "archive_file" "this" {
  type        = "zip"
  source_file = "index.mjs"
  output_path = "index.zip"
  # source_content_filename = "index.mjs"
}

resource "aws_lambda_function" "this" {
  function_name = "${var.projectname}-lmd"
  role          = aws_iam_role.this.arn
  runtime       = "nodejs24.x"
  filename      = archive_file.this.output_path
  handler       = "index.handler"
  package_type  = "Zip"
}
