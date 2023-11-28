resource "aws_api_gateway_rest_api" "uploader_api_gateway" {
  name = "VAR-API"
}

resource "aws_api_gateway_resource" "uploader_resource" {
  rest_api_id = aws_api_gateway_rest_api.uploader_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.uploader_api_gateway.root_resource_id
  path_part   = "request-upload"
}

resource "aws_api_gateway_method" "uploader_method" {
  rest_api_id   = aws_api_gateway_rest_api.uploader_api_gateway.id
  resource_id   = aws_api_gateway_resource.uploader_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.uploader_cognito_authorizer.id
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.uploader_api_gateway.id
  stage_name  = "dev"
}

resource "aws_api_gateway_authorizer" "uploader_cognito_authorizer" {
  name            = "UploaderCognitoAuthorizer"
  rest_api_id     = aws_api_gateway_rest_api.uploader_api_gateway.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [aws_cognito_user_pool.main.arn]
}


module "rest_backend" {
  source = "./rest_backend"

  lambda_bucket                    = var.lambda_bucket
  upload_request_lambda_bundle_sha = var.upload_request_lambda_bundle_sha
  api_gateway_execution_arn        = "${aws_api_gateway_rest_api.uploader_api_gateway.execution_arn}/*/*"
  rest_api_id                      = aws_api_gateway_rest_api.uploader_api_gateway.id
  api_resource_id                  = aws_api_gateway_resource.uploader_resource.id
}
