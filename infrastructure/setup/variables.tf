variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "terraform_state_bucket" {
  description = "The AWS S3 bucket used to store terraform state"
  type        = string
}

variable "terraform_state_s3_key" {
  description = "The terraform state file key on AWS S3"
  type        = string
  default     = "var-state/terraform.tfstate"
}

variable "terraform_state_lock_dynamodb_table" {
  description = "The AWS DynamoDB table name to be used for terraform state lock"
  type        = string
  default     = "var-terraform-state-lock"
}
