variable "nickname" {
  default     = ""
  description = "Distinguishing nickname for the set of resources contained within"
  type        = string

  validation {
    condition     = length(var.nickname)>0
    error_message = "You must provide nickname"
  }
}