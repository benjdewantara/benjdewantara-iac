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

data "local_file" "this" {
  filename = "${path.module}/sfn_definition.json"
}

resource "aws_sfn_state_machine" "this" {
  name     = var.projectname
  role_arn = aws_iam_role.this.arn

  definition = data.local_file.this.content
}
