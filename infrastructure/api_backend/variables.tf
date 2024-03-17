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

variable "db_user" {
  description = "Database master user"
  type = string
  default = "postgres"
}

variable "private_subnet_id_az1" {
  description = "ID of the private subnet in AZ1"
  type        = string
}

variable "private_subnet_id_az2" {
  description = "ID of the private subnet in AZ2"
  type        = string
}

variable "vpc_id" {
  description = "ID of theVPC"
  type        = string
}