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

variable "lambda_bucket" {
  description = "The AWS S3 bucket for storing lambda function codes"
  type        = string
}

variable "github_repo" {
  description = "Github repo to be used to allow github actions to have access to the AWS account via OIDC in this format: <GITHUB_OWNER>/<GITHUB_REPO>"
  type        = string
  default     = ""
}

variable "main_domain" {
  description = "The main domain for which to create the hosted zone"
  type        = string
  default     = ""
}
