variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "lambda_bucket" {
  description = "The AWS S3 bucket for storing lambda function codes"
  type        = string
}

variable "upload_request_lambda_bundle_sha" {
  description = "Uploader lambda function zip sha to be used in source_code_hash"
  type        = string
}

variable "get_users_lambda_bundle_sha" {
  description = "Create user lambda function zip sha to be used in source_code_hash"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN of var API Gateway resource"
  type        = string
}

variable "rest_api_id" {
  description = "Rest API ID"
  type        = string
}

variable "api_root_resource_id" {
  description = "API Gateway root resource ID"
  type        = string
}

variable "authorizer_id" {
  description = "API Gateway authorizer ID"
  type        = string
}

variable "user_pool_id" {
  description = "Cognito user pool ID"
  type        = string
}

