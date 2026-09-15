variable "arn_iam_roles_incoming" { type = list(string) }
variable "aws_profile" { type = string }
variable "projectname" { type = string }
# variable "specs" { type = object({}) }

module "iam" {
  source = "../iam"

  aws_profile            = var.aws_profile
  projectname            = var.projectname
  arn_iam_roles_incoming = var.arn_iam_roles_incoming
}
