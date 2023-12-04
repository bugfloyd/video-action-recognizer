resource "aws_lambda_function" "users_lambda" {
  function_name = "var_users"
  handler       = "dist/index.handler"
  role          = aws_iam_role.users_lambda_exec_role.arn
  runtime       = "nodejs18.x"

  # Assume you have packaged your Lambda function code into a ZIP file and have uploaded it to S3
  s3_bucket        = var.lambda_bucket
  s3_key           = "rest_backend/users/function.zip"
  source_code_hash = var.users_lambda_bundle_sha

  environment {
    variables = {
      REGION       = var.aws_region
      USER_POOL_ID = var.user_pool_id
    }
  }
}

# IAM role for the Lambda function
resource "aws_iam_role" "users_lambda_exec_role" {
  name = "users_lambda_exec_role"

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

resource "aws_iam_policy" "users_lambda_logging_policy" {
  name = "users_lambda_logging_policy"
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

resource "aws_iam_policy" "cognito_policy" {
  name        = "CognitoListUsersPolicy"
  description = "Policy to allow Lambda function to list Cognito users"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "cognito-idp:ListUsers"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:cognito-idp:*:*:userpool/${var.user_pool_id}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cognito_policy_attachment" {
  role       = aws_iam_role.users_lambda_exec_role.name
  policy_arn = aws_iam_policy.cognito_policy.arn
}

resource "aws_iam_role_policy_attachment" "users_lambda_logs_attachment" {
  role       = aws_iam_role.users_lambda_exec_role.name
  policy_arn = aws_iam_policy.users_lambda_logging_policy.arn
}

resource "aws_lambda_permission" "users_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeCreateUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.users_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Depends on the API Gateway deployment to exist before permission is granted
  source_arn = var.api_gateway_execution_arn
}

resource "aws_api_gateway_resource" "users_resource" {
  rest_api_id = var.rest_api_id
  parent_id   = var.api_root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_method" "users_method" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.users_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "users_lambda_integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.users_resource.id
  http_method             = aws_api_gateway_method.users_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.users_lambda.invoke_arn
}
