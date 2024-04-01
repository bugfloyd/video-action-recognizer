# API Gateway resources
resource "aws_api_gateway_resource" "results_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_rest_api.var_rest_backend.root_resource_id
  path_part   = "results"
}

resource "aws_api_gateway_resource" "user_results_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_resource.results_resource.id
  path_part   = "{userId}"
}

resource "aws_api_gateway_resource" "file_results_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_resource.user_results_resource.id
  path_part   = "{fileId}"
}

resource "aws_api_gateway_resource" "result_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_resource.file_results_resource.id
  path_part   = "{resultId}"
}

# API Gateway http methods
resource "aws_api_gateway_method" "post_result" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.file_results_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "get_results" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.results_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

#resource "aws_api_gateway_method" "get_user_results" {
#  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
#  resource_id   = aws_api_gateway_resource.user_results_resource.id
#  http_method   = "GET"
#  authorization = "COGNITO_USER_POOLS"
#  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
#}

resource "aws_api_gateway_method" "get_file_results" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.file_results_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "get_result" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.result_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "patch_result" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.result_resource.id
  http_method   = "PATCH"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "delete_result" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.result_resource.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

# API Gateway Lambda Integrations
resource "aws_api_gateway_integration" "get_results_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.results_resource.id
  http_method             = aws_api_gateway_method.get_results.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

#resource "aws_api_gateway_integration" "get_user_results_lambda_integration" {
#  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
#  resource_id             = aws_api_gateway_resource.user_results_resource.id
#  http_method             = aws_api_gateway_method.get_user_results.http_method
#  integration_http_method = "POST"
#  type                    = "AWS_PROXY"
#  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
#}

resource "aws_api_gateway_integration" "get_file_results_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.file_results_resource.id
  http_method             = aws_api_gateway_method.get_file_results.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "post_result_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.file_results_resource.id
  http_method             = aws_api_gateway_method.post_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "get_result_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.result_resource.id
  http_method             = aws_api_gateway_method.get_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "patch_result_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.result_resource.id
  http_method             = aws_api_gateway_method.patch_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "delete_result_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.result_resource.id
  http_method             = aws_api_gateway_method.delete_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}