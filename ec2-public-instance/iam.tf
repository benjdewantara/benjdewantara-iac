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
          "Sid" : "AllowEC2",
          "Effect" : "Allow",
          "Action" : "ec2:*",
          "Resource" : "*"
        },
        # {
        #   "Sid" : "AllowS3",
        #   "Effect" : "Allow",
        #   "Action" : "s3:*",
        #   "Resource" : "*"
        # },
        # {
        #   "Sid" : "AllowKMS",
        #   "Effect" : "Allow",
        #   "Action" : "kms:*",
        #   "Resource" : "*"
        # },
        {
          "Sid" : "AllowSSM",
          "Effect" : "Allow",
          "Action" : [
            "ec2messages:*",
            "ssm:*",
            "ssmmessages:*"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "AllowCloudWatchLogs",
          "Effect" : "Allow",
          "Action" : "logs:*",
          "Resource" : "*"
        },
        {
          "Sid" : "AllowCloudWatch",
          "Effect" : "Allow",
          "Action" : "cloudwatch:*",
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
