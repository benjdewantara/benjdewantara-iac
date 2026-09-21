resource "aws_iam_role" "that_codebuild_starter" {
  name = var.iam_role_name_codebuild_starter

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "AWS" : [
            var.arn_iam_role_parent
          ],
        }
      }
    ]
    }
  )
}

resource "aws_iam_role_policy" "that_codebuild_starter" {
  role = aws_iam_role.that_codebuild_starter.name
  name = "CodeBuild-starter-inline"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "CodeBuild",
          "Effect" : "Allow",
          "Action" : [
            "codebuild:StartBuild",
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}
