provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  analysis_core_container_name = "main"
}

module "api_backend" {
  source = "./api_backend"

  aws_region                        = var.aws_region
  lambda_bucket                     = var.lambda_bucket
  rest_backend_lambda_bundle_sha    = var.rest_backend_lambda_bundle_sha
  cognito_domain_prefix             = var.cognito_domain_prefix
  cloudfront_distribution_domain    = aws_cloudfront_distribution.s3_distribution.domain_name
  cloudfront_private_key_secret_arn = var.cloudfront_private_key_arn
  cloudfront_public_key_id          = aws_cloudfront_public_key.main.id
}

output "rest_backend_lambda_exec_role_name" {
  value = module.api_backend.rest_backend_lambda_exec_role_name
}

output "api_gateway_id" {
  value = module.api_backend.api_gateway_id
}

output "cognito_user_pool_client_id" {
  value = module.api_backend.cognito_user_pool_client_id
}

output "cognito_user_pool_domain" {
  value = module.api_backend.cognito_user_pool_domain
}

output "cognito_user_pool_id" {
  value = module.api_backend.cognito_user_pool_id
}

output "cognito_user_pool_resource_server_identifier" {
  value = module.api_backend.cognito_user_pool_resource_server_identifier
}