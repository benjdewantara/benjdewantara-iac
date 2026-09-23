variable "arn_iam_role_name_codebuild_starter" { type = string }
variable "projectname" { type = string }

resource "aws_iam_role" "this" {
  name = var.projectname

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "this1" {
  role = aws_iam_role.this.name
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
            "logs:PutLogEvents",
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "this2" {
  role = aws_iam_role.this.name
  name = "EventBridge-inline"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "EventBridge",
          "Effect" : "Allow",
          "Action" : [
            "events:PutTargets",
            "events:PutRule",
            "events:DescribeRule",
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "this3" {
  role = aws_iam_role.this.name
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

data "template_file" "this" {
  template = file("${path.module}/sfn_definition.json")

  vars = {
    arn_iam_role_name_codebuild_starter = var.arn_iam_role_name_codebuild_starter
  }
}

resource "aws_sfn_state_machine" "this" {
  name     = var.projectname
  role_arn = aws_iam_role.this.arn

  definition = data.template_file.this.rendered
}

data "local_file" "this_sfn_b" {
  filename = "${path.module}/sfn_definition-b.json"
}

resource "aws_sfn_state_machine" "this_sfn_b" {
  name     = "${var.projectname}-b-JSONata-tryout"
  role_arn = aws_iam_role.this.arn

  definition = data.local_file.this_sfn_b.content
}

data "local_file" "this_sfn_c" {
  filename = "${path.module}/sfn_definition-c.json"
}

resource "aws_sfn_state_machine" "this_sfn_c" {
  name     = "${var.projectname}-c-S3-howto"
  role_arn = aws_iam_role.this.arn

  definition = data.local_file.this_sfn_c.content
}
