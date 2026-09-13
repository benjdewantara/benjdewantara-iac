# provider "aws" {
#   profile = var.aws_profile_a
#   region  = "ap-southeast-1"
# }

module "iam" {
  source = "../iam"

  aws_profile            = var.aws_profile_a
  projectname            = var.projectname
  arn_iam_roles_incoming = var.arn_iam_roles_incoming
}
