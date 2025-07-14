
variable "image_version" {
  description = "Container Image Version To Deploy"
  default     = ""
}

variable "aws_account_id" {
  description = "AWS Account ID"
  default     = ""
  sensitive   = true
}
