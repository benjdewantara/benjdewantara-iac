variable "aws_profile" { type = string }
variable "portal_url" { type = string }
variable "projectname" { type = string }
variable "region" { type = string }
variable "static_token" { type = string }

provider "aws" {
  profile = var.aws_profile
  region  = var.region
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
          "Service" : [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = {
    iacpath = "lambda-sns-eventbridge/main.tf"
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.this.name
}

data "template_file" "this" {
  template = file("${path.module}/script-local/index.mjs.template")

  vars = {
    portal_url   = var.portal_url
    static_token = var.static_token
  }
}

resource "local_file" "this" {
  filename = "${path.module}/script-local/index.mjs"
  content  = data.template_file.this.rendered
}

data "archive_file" "this" {
  depends_on = [local_file.this]

  type        = "zip"
  source_dir  = "./script-local"
  output_path = "script-local.zip"
}

resource "aws_lambda_function" "this" {
  function_name = var.projectname
  role          = aws_iam_role.this.arn
  runtime       = "nodejs24.x"

  package_type = "Zip"
  handler      = "index.handler"

  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  tags = {
    iacpath = "lambda-sns-eventbridge/main.tf"
  }
}

resource "aws_sns_topic" "this" {
  display_name = var.projectname
  name         = var.projectname

  tags = {
    iacpath = "lambda-sns-eventbridge/main.tf"
  }
}

resource "aws_sns_topic_subscription" "this" {
  endpoint  = aws_lambda_function.this.arn
  protocol  = "lambda"
  topic_arn = aws_sns_topic.this.arn
}
