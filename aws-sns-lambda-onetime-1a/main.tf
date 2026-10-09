variable "aws_profile_this" { type = string }
variable "projectname" { type = string }

provider "aws" {
  region  = "ap-southeast-1"
  profile = var.aws_profile_this
}

resource "local_file" "this" {
  filename = "script-temp/index.mjs"
  content  = file("${path.module}/../scripts/lambda-print.js")
}

resource "archive_file" "this" {
  type        = "zip"
  source_dir  = "./script-temp"
  output_path = "${local_file.this.content_md5}.tmp"
}

resource "aws_lambda_function" "this" {
  function_name = "${var.projectname}-lmd"
  role          = aws_iam_role.this.arn
  runtime       = "nodejs24.x"
  filename      = archive_file.this.output_path
  handler       = "index.handler"
  package_type  = "Zip"
}

resource "aws_sns_topic" "this" {
  display_name      = "${var.projectname}-display_name"
  name              = "${var.projectname}-name"
  signature_version = 1
}

resource "aws_sns_topic_subscription" "this" {
  endpoint  = aws_lambda_function.this.arn
  protocol  = "lambda"
  topic_arn = aws_sns_topic.this.arn
}

resource "aws_lambda_permission" "this" {
  source_arn    = aws_sns_topic.this.arn
  function_name = aws_lambda_function.this.function_name
  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
}
