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
  region  = "us-east-1"
}

locals {
  role_arn = "awcs-codepipeline"
}

module "this" {
  source = "../../apache-web-creator-system/user-apache-app/codepipeline"

  nickname                              = "pache-1"
  codepipeline_role_name                = "awcs-codepipeline"
  codepipeline_artifact_store_s3_bucket = "benj-ndfknxti"

  code_pipeline_stages_json_obj_stringified = jsonencode([
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
            "RepositoryName"       = "local.codecommit_repo_name"
          }
          # input_artifacts = []
          # namespace          = ""
          output_artifacts = ["SourceArtifact"]
          # region             = ""
          role_arn  = local.role_arn
          run_order = 3
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
          role_arn  = local.role_arn
          run_order = 2
          # timeout_in_minutes = 3600
        }
      ]
    },
    {
      name = "Stage-Three-wkwk"
      actions = [
        {
          category = "Build"
          name     = "Stage-Three-Build"
          owner    = "AWS"
          provider = "CodeBuild"
          version  = "1"

          configuration = {
            # BatchEnabled= 'true'
            CombineArtifacts = true
            ProjectName      = "my-build-project"
            PrimarySource    = "MyApplicationSource1"
            EnvironmentVariables = jsonencode([
              {
                name  = "TEST_VARIABLE",
                value = "TEST_VALUE",
                type  = "PLAINTEXT"
              },
              {
                name  = "ParamStoreTest",
                value = "PARAMETER_NAME",
                type  = "PARAMETER_STORE"
              }
            ])
          }
          input_artifacts = ["MyApplicationSource1"]
          # namespace          = ""
          output_artifacts = []
          # region             = ""
          role_arn  = local.role_arn
          run_order = 1
          # timeout_in_minutes = 3600
        }
      ]
    }
  ]
  )
}