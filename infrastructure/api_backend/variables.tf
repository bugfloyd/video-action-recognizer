variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "lambda_bucket" {
  description = "The AWS S3 bucket for storing lambda function codes"
  type        = string
}

variable "rest_backend_lambda_bundle_sha" {
  description = "User lambda function zip sha to be used in source_code_hash"
  type        = string
}

variable "cognito_domain_prefix" {
  description = "The prefix for the Amazon Cognito domain."
  type        = string
}