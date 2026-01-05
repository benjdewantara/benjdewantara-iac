module "iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = local.projectname
  path        = "/"
  description = "My example policy"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowCloudWatchAgentWizard",
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:*",
            "ec2:*",
            "ec2messages:*",
            "logs:*",
            "ssm:*",
            "ssmmessages:*"
          ],
          "Resource" : "*"
        },
      ]
    }
  )

  tags = {
    iacpath = "ec2-public-instance/iam.tf"
  }
}

module "iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role"

  name                    = local.projectname
  use_name_prefix         = false
  create_instance_profile = true

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole",
      ]
      principals = [
        {
          type = "Service"
          identifiers = [
            "ec2.amazonaws.com",
          ]
        }
      ]
      # condition = [
      #   {
      #     test     = "StringEquals"
      #     variable = "sts:ExternalId"
      #     values   = ["some-secret-id"]
      #   }
      # ]
    }
  }

  policies = {
    custom123 = module.iam_policy.arn
  }

  tags = {
    iacpath = "ec2-public-instance/iam.tf"
  }
}
