variable "projectname" { type = string }
variable "aws_profile_this" { type = string }

provider "aws" {
  profile = var.aws_profile_this
  region  = "ap-southeast-1"
}

resource "aws_iam_user" "this" {
  name = var.projectname
}

resource "aws_iam_policy" "this" {
  name = var.projectname
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowCloudWatchAgentConfigurerWizard",
          "Effect" : "Allow",
          "Action" : [
            "sts:GetFederationToken",
          ],
          "Resource" : "*"
        },
      ]
    }
  )
}

resource "aws_iam_policy_attachment" "this" {
  name       = var.projectname
  policy_arn = aws_iam_policy.this.arn
  users      = [aws_iam_user.this.name]
}
