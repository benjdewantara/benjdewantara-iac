module "iam" {
  source = "../iam"

  aws_profile            = var.aws_profile
  projectname            = var.projectname
  arn_iam_roles_incoming = var.arn_iam_roles_incoming
}
