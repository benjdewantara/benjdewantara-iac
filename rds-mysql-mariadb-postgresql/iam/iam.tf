provider "aws" {
  profile = var.aws_profile
}

resource "aws_iam_role" "this" {
  name = var.projectname
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "sts:AssumeRole"
          ],
          "Principal" : {
            "AWS" : var.arn_iam_roles_incoming
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "this" {
  name = var.projectname
  role = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "account:Get*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

}
