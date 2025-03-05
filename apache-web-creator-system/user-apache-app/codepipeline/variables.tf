variable "nickname" {
  default     = ""
  description = "Distinguishing nickname for the set of resources contained within"
  type        = string

  validation {
    condition     = length(var.nickname)>0
    error_message = "You must provide nickname"
  }
}

variable "codepipeline_role_name" {
  default     = ""
  description = "IAM Role ARN used by CodePipeline"
  type        = string

  validation {
    condition     = length(var.codepipeline_role_name)>0
    error_message = "You must provide codepipeline_role_arn"
  }
}

variable "codepipeline_artifact_store_s3_bucket" {
  default     = ""
  description = "S3 bucket used to store CodePipeline artifacts"
  type        = string

  validation {
    condition     = length(var.codepipeline_artifact_store_s3_bucket)>0
    error_message = "You must provide codepipeline_role_arn1"
  }
}
