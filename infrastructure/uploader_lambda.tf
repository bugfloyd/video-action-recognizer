resource "aws_lambda_function" "uploader_lambda" {
  function_name = "var_uploader"
  handler       = "dist/index.handler"
  role          = aws_iam_role.uploader_lambda_exec_role.arn
  runtime       = "nodejs18.x"

  # Assume you have packaged your Lambda function code into a ZIP file and have uploaded it to S3
  s3_bucket        = var.lambda_bucket
  s3_key           = "uploader/latest/function.zip"
  source_code_hash = var.uploader_lambda_bundle_sha

  # environment {
  #   variables = {
  #     AENV_VAR_NAME = "VAR_VALUE"
  #   }
  # }
}

# IAM role for the Lambda function
resource "aws_iam_role" "uploader_lambda_exec_role" {
  name = "uploader_lambda_exec_role"

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

resource "aws_iam_policy" "uploader_lambda_logging_policy" {
  name = "uploader_lambda_logging_policy"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_policy" "uploader_lambda_task_policy" {
  name = "uploader_lambda_task_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
    ],
  })
}
resource "aws_iam_role_policy_attachment" "uploader_lambda_logs_attachment" {
  role       = aws_iam_role.uploader_lambda_exec_role.name
  policy_arn = aws_iam_policy.uploader_lambda_logging_policy.arn
}
resource "aws_iam_role_policy_attachment" "uploader_lambda_task_attachment" {
  role       = aws_iam_role.uploader_lambda_exec_role.name
  policy_arn = aws_iam_policy.uploader_lambda_task_policy.arn
}


resource "aws_api_gateway_rest_api" "uploader_api_gateway" {
  name = "UploadAPI"
}

resource "aws_api_gateway_resource" "uploader_resource" {
  rest_api_id = aws_api_gateway_rest_api.uploader_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.uploader_api_gateway.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "uploader_method" {
  rest_api_id   = aws_api_gateway_rest_api.uploader_api_gateway.id
  resource_id   = aws_api_gateway_resource.uploader_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.uploader_cognito_authorizer.id
}

resource "aws_api_gateway_integration" "uploader_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.uploader_api_gateway.id
  resource_id             = aws_api_gateway_resource.uploader_resource.id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.uploader_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_integration.uploader_lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.uploader_api_gateway.id
  stage_name  = "prod"
}

resource "aws_api_gateway_authorizer" "uploader_cognito_authorizer" {
  name            = "UploaderCognitoAuthorizer"
  rest_api_id     = aws_api_gateway_rest_api.uploader_api_gateway.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [aws_cognito_user_pool.main.arn]
}

resource "aws_lambda_permission" "api_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.uploader_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Depends on the API Gateway deployment to exist before permission is granted
  source_arn = "${aws_api_gateway_rest_api.uploader_api_gateway.execution_arn}/*/*"
}
