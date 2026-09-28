variable "aws_profile_this" { type = string }
variable "projectname" { type = string }
variable "source_instance_id" { type = string }

provider "aws" {
  profile = var.aws_profile_this
  region  = "ap-southeast-1"
}

resource "aws_ami_from_instance" "this" {
  name               = var.projectname
  source_instance_id = var.source_instance_id
}
