variable "system_nickname" {
  default     = ""
  description = "IAM Role ARN used by CodePipeline"
  type        = string

  validation {
    condition     = length(var.system_nickname)>0
    error_message = "You must provide system_nickname"
  }
}
