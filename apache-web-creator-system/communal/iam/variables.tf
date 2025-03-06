variable "nickname" {
  default     = ""
  description = "Name contained within IAM Role name"
  type        = string

  validation {
    condition     = length(var.nickname) > 0
    error_message = "You must provide system_nickname"
  }
}

variable "assume_role_policy" {
  default     = ""
  description = "Trust relationship document"
  type        = string

  validation {
    condition     = length(var.assume_role_policy) > 0
    error_message = "You must provide assume_role_policy"
  }
}

variable "policy_inline_json" {
  default     = ""
  description = "IAM Policy Inline"
  type        = string

  validation {
    condition     = length(var.policy_inline_json) > 0
    error_message = "You must provide policy_inline_json"
  }
}