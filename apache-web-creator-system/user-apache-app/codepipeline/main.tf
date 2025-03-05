terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

provider "aws" {
  profile = "benj"
  region  = "ap-southeast-3"
}

locals {
  codepipeline_name    = "cp-${var.nickname}"
  codecommit_repo_name = "cc-${var.nickname}"
}

locals {
  codepipeline_stages = [
    {
      name = "Stage-One"
      actions = [
        {
          category = "Source"
          name     = "Stage-One-Source"
          owner    = "AWS"
          provider = "CodeCommit"
          version  = "1"

          configuration = {
            "BranchName"           = "main"
            "OutputArtifactFormat" = "CODE_ZIP"
            "PollForSourceChanges" = false
            "RepositoryName"       = local.codecommit_repo_name
          }
          # input_artifacts = []
          # namespace          = ""
          output_artifacts = ["output_artifact_item_01"]
          # region             = ""
          # role_arn           = ""
          # run_order          = 1
          # timeout_in_minutes = 3600
        }
      ]
    },
    {
      name = "Stage-Two"
      actions = [
        {
          category = "Approval"
          name     = "Stage-Two-Approval"
          owner    = "AWS"
          provider = "Manual"
          version  = "1"

          configuration = {}
          # input_artifacts = []
          # namespace          = ""
          output_artifacts = []
          # region             = ""
          # role_arn           = ""
          # run_order          = 1
          # timeout_in_minutes = 3600
        }
      ]
    }
  ]
}

data "aws_iam_role" "codepipeline" {
  name = var.codepipeline_role_name
}

resource "aws_codepipeline" "this" {
  name     = local.codepipeline_name
  role_arn = data.aws_iam_role.codepipeline.arn

  artifact_store {
    location = var.codepipeline_artifact_store_s3_bucket
    type     = "S3"
  }

  # stage {
  #   name = ""
  #   action {
  #     category = ""
  #     name     = ""
  #     owner    = ""
  #     provider = ""
  #     version  = ""
  #
  #     configuration = {}
  #     input_artifacts = []
  #     namespace          = ""
  #     output_artifacts = []
  #     region             = ""
  #     role_arn           = ""
  #     run_order          = 1
  #     timeout_in_minutes = 3600
  #   }
  # }

  dynamic "stage" {
    for_each = local.codepipeline_stages
    content {
      name = stage.value.name

      dynamic "action" {
        for_each = stage.value.actions
        content {
          category         = action.value.category
          name             = action.value.name
          owner            = action.value.owner
          provider         = action.value.provider
          version          = action.value.version
          configuration    = action.value.configuration
          # input_artifacts    = action.value.input_artifacts
          # namespace          = action.value.namespace
          output_artifacts = action.value.output_artifacts
          # region             = action.value.region
          # role_arn           = action.value.role_arn
          # run_order          = action.value.run_order
          # timeout_in_minutes = action.value.timeout_in_minutes
        }
      }
    }
  }
}