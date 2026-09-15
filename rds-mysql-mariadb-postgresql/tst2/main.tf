variable "aws_profile" { type = string }
variable "projectname" { type = string }

module "vpc" {
  source = "../vpc"

  aws_profile = var.aws_profile
  aws_region  = "ap-southeast-1"
  projectname = var.projectname
  vpc_cidr    = "10.0.0.0/24"
}

# module "rds" {
#   source = "../rds-single"
#
#   aws_profile = var.aws_profile
#   projectname = var.projectname
#   aws_region  = "ap-southeast-1"
# }
