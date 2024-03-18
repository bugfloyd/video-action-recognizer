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

  aws_region                     = var.aws_region
  lambda_bucket                  = var.lambda_bucket
  rest_backend_lambda_bundle_sha = var.rest_backend_lambda_bundle_sha
  cognito_domain_prefix          = var.cognito_domain_prefix
}