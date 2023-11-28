variable "lambda_bucket" {
  description = "The AWS S3 bucket for storing lambda function codes"
  type        = string
}

variable "uploader_lambda_bundle_sha" {
  description = "Uploader lambda function zip sha to be used in source_code_hash"
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

variable "api_resource_id" {
  description = "API Gateway resource ID"
  type        = string
}


