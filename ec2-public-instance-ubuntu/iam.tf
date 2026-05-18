module "iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = local.projectname
  path        = "/"
  description = "IAM Policy for ${local.projectname}}"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowCloudWatchAgentConfigurerWizard",
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:PutMetricData",
            "ec2:DescribeTags",
            "ec2:DescribeVolumes",
            "ec2messages:AcknowledgeMessage",
            "ec2messages:DeleteMessage",
            "ec2messages:FailMessage",
            "ec2messages:GetEndpoint",
            "ec2messages:GetMessages",
            "ec2messages:SendReply",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "ssm:DescribeAssociation",
            "ssm:DescribeDocument",
            "ssm:GetDeployablePatchSnapshotForInstance",
            "ssm:GetDocument",
            "ssm:GetManifest",
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:ListAssociations",
            "ssm:ListInstanceAssociations",
            "ssm:PutComplianceItems",
            "ssm:PutConfigurePackageResult",
            "ssm:PutInventory",
            "ssm:UpdateAssociationStatus",
            "ssm:UpdateInstanceAssociationStatus",
            "ssm:UpdateInstanceInformation",
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
    }
  }

  policies = {
    custom123 = module.iam_policy.arn
  }

  tags = {
    iacpath = "ec2-public-instance/iam.tf"
  }
}
