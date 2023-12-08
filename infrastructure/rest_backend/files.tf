resource "aws_lambda_function" "files_lambda" {
  function_name = "VarFiles"
  handler       = "dist/index.handler"
  role          = aws_iam_role.files_management_lambda_exec_role.arn
  runtime       = "nodejs18.x"

  # Assume you have packaged your Lambda function code into a ZIP file and have uploaded it to S3
  s3_bucket        = var.lambda_bucket
  s3_key           = "rest_backend/files/function.zip"
  source_code_hash = var.files_lambda_bundle_sha

  environment {
    variables = {
      REGION = var.aws_region
    }
  }
}

resource "aws_iam_role" "files_management_lambda_exec_role" {
  name = "VarFilesLambdaExecRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

# IAM role policy attachments
resource "aws_iam_role_policy_attachment" "files_lambda_cognito_policy_attachment" {
  role       = aws_iam_role.files_management_lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_cognito_policy.arn
}

resource "aws_iam_role_policy_attachment" "files_lambda_logs_attachment" {
  role       = aws_iam_role.files_management_lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

resource "aws_lambda_permission" "files_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeFiles"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.files_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Depends on the API Gateway deployment to exist before permission is granted
  source_arn = var.api_gateway_execution_arn
}

# API Gateway resources
resource "aws_api_gateway_resource" "files_resource" {
  rest_api_id = var.rest_api_id
  parent_id   = var.api_root_resource_id
  path_part   = "files"
}

resource "aws_api_gateway_resource" "file_resource" {
  rest_api_id = var.rest_api_id
  parent_id   = aws_api_gateway_resource.files_resource.id
  path_part   = "{file_id}"
}

# API Gateway http methods
resource "aws_api_gateway_method" "get_files" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.files_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_method" "post_file" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.files_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_method" "get_file" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.file_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_method" "patch_file" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.file_resource.id
  http_method   = "PATCH"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_method" "delete_file" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.file_resource.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

# API Gateway Lambda Integratons
resource "aws_api_gateway_integration" "get_files_lambda_integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.files_resource.id
  http_method             = aws_api_gateway_method.get_files.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.files_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "post_file_lambda_integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.files_resource.id
  http_method             = aws_api_gateway_method.post_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.files_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "get_file_lambda_integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.file_resource.id
  http_method             = aws_api_gateway_method.get_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.files_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "patch_file_lambda_integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.file_resource.id
  http_method             = aws_api_gateway_method.patch_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.files_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "delete_file_lambda_integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.file_resource.id
  http_method             = aws_api_gateway_method.delete_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.files_lambda.invoke_arn
}
