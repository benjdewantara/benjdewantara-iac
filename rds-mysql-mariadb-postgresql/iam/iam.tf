provider "aws" {
  profile = var.aws_profile
  # region  = "ap-southeast-1"
}

module "iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = var.projectname
  path        = "/"
  description = "IAM Policy for ${var.projectname}}"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowExternal",
          "Effect" : "Allow",
          "Action" : [
            "account:GetAccountInformation",
          ],
          "Resource" : "*"
        },
      ]
    }
  )

  tags = {
    iacpath = "iam/iam.tf"
  }
}

module "iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role"

  name                    = var.projectname
  use_name_prefix         = false
  create_instance_profile = true

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole",
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = var.arn_iam_roles_incoming
        }
      ]
    }
  }

  policies = {
    a1 = module.iam_policy.arn
    a2 = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  tags = {
    iacpath = "iam/iam.tf"
  }
}
