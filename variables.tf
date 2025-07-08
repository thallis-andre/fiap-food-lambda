
variable "image_version" {
  description = "Container Image Version To Deploy"
  default     = ""
}

variable "aws_account_id" {
  description = "AWS Account ID"
  default     = ""
  sensitive   = true
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool"
  default     = ""
  sensitive   = true
}

variable "cognito_client_id" {
  description = "Client Id to access Cognito"
  default     = ""
  sensitive   = true
}

variable "aws_access_key_id" {
  description = "AWS Access Credentials"
  default     = ""
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Access Credentials"
  default     = ""
  sensitive   = true
}

variable "aws_session_token" {
  description = "AWS Access Credentials"
  default     = ""
  sensitive   = true
}
