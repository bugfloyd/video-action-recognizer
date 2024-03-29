provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_state_bucket
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.terraform_state_lock_dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "TerraformStateLocking"
  }
}

# S3 bucket to store lambda function codes
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket
}

module "domain" {
  source = "./domain"
  count = var.main_domain != "" ? 1 : 0

  main_domain = var.main_domain
}

output "name_servers" {
  value = length(module.domain) > 0 ? module.domain[0].name_servers : ["No domain provided"]
}

output "zone_id" {
  value = length(module.domain) > 0 ? module.domain[0].zone_id : "No domain provided"
}

module "github" {
  source = "./github"
  count = var.github_repo != "" ? 1 : 0

  github_repo = var.github_repo
}

output "github_pipeline_execution_role_arn" {
  value = length(module.github) > 0 ? module.github[0].pipeline_execution_role_arn : "No GitHub repo provided"
}