module "iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name = local.nickname
  path = "/"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowLogsAndSecretsManager",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "secretsmanager:GetSecretValue",
          ],
          "Resource" : "*"
        },
      ]
    }
  )
}

module "iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role"

  name                    = local.nickname
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
            "codebuild.amazonaws.com"
          ]
        }
      ]
    }
  }

  policies = {
    a1 = module.iam_policy.arn
    a2 = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }
}
