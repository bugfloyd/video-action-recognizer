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
  db_user                        = var.db_user
  private_subnet_id_az1          = aws_subnet.private_subnet_az1.id
  private_subnet_id_az2          = aws_subnet.private_subnet_az2.id
  vpc_id                         = aws_vpc.main.id
}

module "vpn" {
  source = "./vpn"
  count  = var.setup_vpn == true && var.main_domain_zone_id != "" ? 1 : 0

  private_subnet_id_az1         = aws_subnet.private_subnet_az1.id
  private_subnet_id_az2         = aws_subnet.private_subnet_az2.id
  private_subnet_cidr_block_az1 = aws_subnet.private_subnet_az1.cidr_block
  private_subnet_cidr_block_az2 = aws_subnet.private_subnet_az2.cidr_block
  main_zone_id                  = var.main_domain_zone_id
  vpc_id                        = aws_vpc.main.id
  vpn_client_cidr_block         = "10.1.0.0/16"
}