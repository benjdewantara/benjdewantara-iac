provider "aws" {
  profile = "benj3"
  region  = "ap-southeast-1"
}

locals {
  nickname            = "bnj-test"
  bucketname          = "${local.nickname}-temporal"
  secretsmanager_name = "${local.nickname}/test/secrets"
  time_now            = timestamp()
}

resource "random_string" "this" {
  keepers = { marker = local.time_now }

  length    = 4
  lower     = true
  min_lower = 4
  special   = false
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucketname
}

data "template_file" "this" {
  template = file("${path.module}/buildspec.yml")

  vars = {
    secretsmanager_name = local.secretsmanager_name
  }
}

resource "aws_codebuild_project" "this" {
  name         = local.nickname
  service_role = module.iam_role.arn

  source {
    type      = "NO_SOURCE"
    buildspec = data.template_file.this.rendered
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  artifacts {
    location               = local.bucketname
    name                   = "${local.nickname}-def"
    namespace_type         = "NONE"
    override_artifact_name = true
    packaging              = "NONE"
    path                   = "/"
    type                   = "S3"
  }
}
