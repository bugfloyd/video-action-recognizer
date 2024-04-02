# API Gateway resources
resource "aws_api_gateway_resource" "files_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_rest_api.var_rest_backend.root_resource_id
  path_part   = "files"
}

resource "aws_api_gateway_resource" "user_files_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_resource.files_resource.id
  path_part   = "{userId}"
}

resource "aws_api_gateway_resource" "generate_signed_url_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_resource.user_files_resource.id
  path_part   = "generate-signed-url"
}

resource "aws_api_gateway_resource" "file_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_resource.user_files_resource.id
  path_part   = "{fileId}"
}

# API Gateway http methods
resource "aws_api_gateway_method" "post_file" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.user_files_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "generate_signed_url" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.generate_signed_url_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "get_files" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.files_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "get_user_files" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.user_files_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "get_file" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.file_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "patch_file" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.file_resource.id
  http_method   = "PATCH"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "delete_file" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.file_resource.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

# API Gateway Lambda Integrations
resource "aws_api_gateway_integration" "get_files_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.files_resource.id
  http_method             = aws_api_gateway_method.get_files.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "get_user_files_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.user_files_resource.id
  http_method             = aws_api_gateway_method.get_user_files.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "post_file_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.user_files_resource.id
  http_method             = aws_api_gateway_method.post_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "generate_signed_url_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.generate_signed_url_resource.id
  http_method             = aws_api_gateway_method.generate_signed_url.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "get_file_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.file_resource.id
  http_method             = aws_api_gateway_method.get_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "patch_file_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.file_resource.id
  http_method             = aws_api_gateway_method.patch_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "delete_file_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id             = aws_api_gateway_resource.file_resource.id
  http_method             = aws_api_gateway_method.delete_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_backend_lambda.invoke_arn
}