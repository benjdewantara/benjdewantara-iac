provider "aws" {
  profile = "benj"
  region  = "ap-southeast-3"
}

locals {
  nickname_local   = "awscli-tester"
  archive_filename = "script-local"
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "./${local.archive_filename}"
  output_path = "${local.archive_filename}.zip"
}

resource "aws_iam_role" "this" {
  name = local.nickname_local

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
    EOF

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]

  tags = {
    "iacpath" = "lambda-awscli/main.tf"
  }
}

resource "aws_lambda_function" "this" {
  function_name = local.nickname_local
  role          = aws_iam_role.this.arn

  # filename         = "${local.archive_filename}.zip"
  filename         = "${local.archive_filename}.zip"
  source_code_hash = data.archive_file.this.output_base64sha256

  handler = "main.functionbenj"
  runtime = "provided.al2023"

  timeout     = 30
  memory_size = 512

  tags = {
    "iacpath" = "lambda-awscli/main.tf"
  }
}
