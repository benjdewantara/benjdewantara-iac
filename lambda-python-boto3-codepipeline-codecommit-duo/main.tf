provider "aws" {
  profile = "benj"
  region  = "ap-southeast-1"
}

resource "aws_cloudwatch_event_rule" "this" {
  description = "This will trigger Lambda after CodePipeline succeeds"
  name        = "cwe-rule-codepipeline-finishes"

  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Instance State-change Notification"],
    "detail" : {
      "state" : ["running"]
    }
  })

  tags = {
    "iacpath" = "lambda-python-boto3-codepipeline-codecommit-duo/main.tf"
  }
}

resource "aws_iam_role" "this" {
  name = "lmd-finishes"

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
    "iacpath" = "lambda-python-boto3-codepipeline-codecommit-duo/main.tf"
  }
}

locals {
  archive_filename = "lambda-python-boto3-codepipeline-codecommit-duo"
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "./${local.archive_filename}"
  output_path = "${local.archive_filename}.zip"
}

resource "aws_lambda_function" "this" {
  function_name = "horbo-route53-updater"
  role          = aws_iam_role.this.arn

  filename         = "${local.archive_filename}.zip"
  source_code_hash = data.archive_file.this.output_base64sha256

  handler = "main.lambda_handler"
  runtime = "python3.9"

  timeout     = 30
  memory_size = 512

  tags = {
    "iacpath" = "lambda-python-boto3-codepipeline-codecommit-duo/main.tf"
  }
}

resource "aws_lambda_permission" "this" {
  source_arn    = aws_cloudwatch_event_rule.this.arn
  function_name = aws_lambda_function.horbo-route53-updater.function_name
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
}

resource "aws_cloudwatch_event_target" "this" {
  arn  = aws_lambda_function.horbo-route53-updater.arn
  rule = aws_cloudwatch_event_rule.this.id
}
