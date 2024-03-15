resource "aws_api_gateway_rest_api" "var_rest_backend" {
  name = "VAR-API"
}

resource "aws_api_gateway_deployment" "api_deployment" {
   depends_on = [
     aws_api_gateway_integration.get_users_lambda_integration,
     aws_api_gateway_integration.get_user_lambda_integration,
     aws_api_gateway_integration.post_user_lambda_integration,
     aws_api_gateway_integration.patch_user_lambda_integration,
     aws_api_gateway_integration.delete_user_lambda_integration
   ]

  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  stage_name  = "dev"
}

resource "aws_api_gateway_authorizer" "var_cognito_authorizer" {
  name            = "VarCognitoAuthorizer"
  rest_api_id     = aws_api_gateway_rest_api.var_rest_backend.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [aws_cognito_user_pool.main.arn]
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.var_rest_backend.id
}
