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

resource "aws_iam_role_policy" "this" {
  role = aws_iam_role.this.name
  name = "${aws_iam_role.this.name}-CloudWatchLogs-inline"

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

data "local_file" "this" {
  filename = "${path.module}/sfn_definition.json"
}

resource "aws_sfn_state_machine" "this" {
  name     = var.projectname
  role_arn = aws_iam_role.this.arn

  definition = data.local_file.this.content
}
