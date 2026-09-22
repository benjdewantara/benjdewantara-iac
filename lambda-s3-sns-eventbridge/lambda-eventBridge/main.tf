variable "aws_profile" { type = string }
variable "projectname" { type = string }
variable "bucketname" { type = string }
variable "region" { type = string }
variable "template_portal_url" { type = string }
variable "template_static_token" { type = string }

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
    iacpath = "lambda-s3-sns-eventbridge/lambda-eventBridge/main.tf"
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.this.name
}

data "template_file" "this" {
  template = file("${path.module}/script-local/index.mjs.template")

  vars = {
    portal_url   = var.template_portal_url
    static_token = var.template_static_token
  }
}

resource "local_file" "this" {
  filename = "${path.module}/script-local/index.mjs"
  content  = data.template_file.this.rendered
}

data "archive_file" "this" {
  depends_on = [local_file.this]

  type        = "zip"
  source_dir  = "${path.module}/script-local"
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
    iacpath = "lambda-s3-sns-eventbridge/lambda-eventBridge/main.tf"
  }
}

# resource "aws_cloudwatch_event_bus" "this" {
#   name = var.projectname
# }

# resource "aws_cloudwatch_event_rule" "this" {
#   name = var.projectname
#
#   event_bus_name = aws_cloudwatch_event_bus.this.name
#
#   # event_pattern = jsonencode({
#   #   "source" : ["aws.s3files"],
#   #   "detail-type" : ["AWS API Call via CloudTrail"],
#   #   "resources" : [
#   #     "arn:aws:s3:::*",
#   #   ],
#   #   "detail" : {
#   #     "eventSource" : ["s3files.amazonaws.com"]
#   #   }
#   # })
#
#   event_pattern = jsonencode({
#     "source" : ["aws.s3"],
#     "detail-type" : ["Object Created"]
#   })
#
#   tags = {
#     iacpath = "lambda-s3-sns-eventbridge/lambda-eventBridge/main.tf"
#   }
# }

# resource "aws_cloudwatch_event_target" "this" {
#   arn            = aws_lambda_function.this.arn
#   rule           = aws_cloudwatch_event_rule.this.name
#   event_bus_name = aws_cloudwatch_event_rule.this.event_bus_name
# }

# resource "aws_lambda_permission" "this" {
#   source_arn    = aws_cloudwatch_event_rule.this.arn
#   function_name = aws_lambda_function.this.function_name
#   action        = "lambda:InvokeFunction"
#   principal     = "events.amazonaws.com"
# }

data "aws_s3_bucket" "this" {
  bucket = var.bucketname
}

resource "aws_lambda_permission" "this" {
  source_arn    = data.aws_s3_bucket.this.arn
  function_name = aws_lambda_function.this.function_name
  action        = "lambda:InvokeFunction"
  principal     = "s3.amazonaws.com"
}

resource "aws_s3_bucket_notification" "this" {
  bucket = data.aws_s3_bucket.this.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
