variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "input_bucket" {
  description = "The AWS S3 bucket for storing input videos"
  type        = string
}

variable "output_bucket" {
  description = "The AWS S3 bucket for storing output videos"
  type        = string
}

variable "lambda_bucket" {
  description = "The AWS S3 bucket for storing lambda function codes"
  type        = string
}

variable "upload_listener_lambda_bundle_sha" {
  description = "Upload listener lambda function zip sha to be used in source_code_hash"
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

variable "db_user" {
  description = "Database master user"
  type = string
  default = "postgres"
}

variable "setup_vpn" {
  description = "Should we setup a VPN server?"
  type = bool
  default = false
}

variable "main_domain_zone_id" {
  description = "Route53 HostedZone ID for the main domain"
  type = string
  default = ""
}
