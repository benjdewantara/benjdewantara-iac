variable "aws_profile" { type = string }
variable "projectname" { type = string }

module "rds" {
  source = "../rds"

  aws_profile = var.aws_profile
  projectname = var.projectname
  aws_region  = "ap-southeast-1"
}
