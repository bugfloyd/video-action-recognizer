# API Gateway resources
resource "aws_api_gateway_resource" "users_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_rest_api.var_rest_backend.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_resource" "user_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_resource.users_resource.id
  path_part   = "{userId}"
}

# API Gateway http methods
resource "aws_api_gateway_method" "get_users" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.users_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
  authorization_scopes = ["https://var.bugfloyd.com/use:var"]
}

resource "aws_api_gateway_method" "post_user" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.users_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
  authorization_scopes = ["https://var.bugfloyd.com/use:var"]
}

resource "aws_api_gateway_method" "get_user" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.user_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
  authorization_scopes = ["https://var.bugfloyd.com/use:var"]
}

resource "aws_api_gateway_method" "patch_user" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.user_resource.id
  http_method   = "PATCH"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
  authorization_scopes = ["https://var.bugfloyd.com/use:var"]
}

resource "aws_api_gateway_method" "delete_user" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.user_resource.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
  authorization_scopes = ["https://var.bugfloyd.com/use:var"]
}

# API Gateway Lambda Integrations
resource "aws_api_gateway_integration" "get_users_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.users_resource.id
  http_method             = aws_api_gateway_method.get_users.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "post_user_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.users_resource.id
  http_method             = aws_api_gateway_method.post_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "get_user_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.user_resource.id
  http_method             = aws_api_gateway_method.get_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "patch_user_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.user_resource.id
  http_method             = aws_api_gateway_method.patch_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "delete_user_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.user_resource.id
  http_method             = aws_api_gateway_method.delete_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}