variable "aws_profile" { type = string }
variable "projectname" { type = string }
variable "region" { type = string }
variable "template_portal_url" { type = string }
variable "template_static_token" { type = string }

provider "aws" {
  profile = var.aws_profile
  region  = var.region
}

module "s3_bucket" {
  source = "./s3"

  aws_profile = var.aws_profile
  projectname = var.projectname
  region      = var.region
}

module "lambda_sns" {
  source = "./lambda-sns"

  aws_profile           = var.aws_profile
  projectname           = "${var.projectname}-sns"
  region                = var.region
  template_portal_url   = var.template_portal_url
  template_static_token = var.template_static_token
}

module "lambda_eventBridge" {
  source = "./lambda-eventBridge"

  aws_profile           = var.aws_profile
  projectname           = "${var.projectname}-eventBridge"
  region                = var.region
  template_portal_url   = var.template_portal_url
  template_static_token = var.template_static_token
}
