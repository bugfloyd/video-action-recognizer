resource "aws_api_gateway_rest_api" "var_backend" {
  name = "VAR-API"
}

module "rest_backend" {
  source = "./rest_backend"

  aws_region                       = var.aws_region
  lambda_bucket                    = var.lambda_bucket
  upload_request_lambda_bundle_sha = var.upload_request_lambda_bundle_sha
  api_gateway_execution_arn        = "${aws_api_gateway_rest_api.var_backend.execution_arn}/*/*"
  rest_api_id                      = aws_api_gateway_rest_api.var_backend.id
  api_root_resource_id             = aws_api_gateway_rest_api.var_backend.root_resource_id
  authorizer_id                    = aws_api_gateway_authorizer.var_cognito_authorizer.id
  users_lambda_bundle_sha          = var.users_lambda_bundle_sha
  user_pool_id                     = aws_cognito_user_pool.main.id
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [module.rest_backend]

  rest_api_id = aws_api_gateway_rest_api.var_backend.id
  stage_name  = "dev"
}

resource "aws_api_gateway_authorizer" "var_cognito_authorizer" {
  name            = "VarCognitoAuthorizer"
  rest_api_id     = aws_api_gateway_rest_api.var_backend.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [aws_cognito_user_pool.main.arn]
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.var_backend.id
}
