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

variable "cloudfront_distribution_domain" {
  description = "CloudFront S3 backed distribution domain"
  type        = string
}

variable "cloudfront_public_key_id" {
  description = "CloudFront public key ID for signing URLs"
  type        = string
}

variable "cloudfront_private_key_secret_arn" {
  description = "CloudFront private key secret ARN for signing URLs"
  type        = string
}

variable "event_bus_name" {
  description = "EventBridge bus name"
  type        = string
}

variable "event_bus_arn" {
  description = "EventBridge bus ARN"
  type        = string
}