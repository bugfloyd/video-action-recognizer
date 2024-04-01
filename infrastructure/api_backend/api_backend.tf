resource "aws_lambda_function" "rest_backend_lambda" {
  function_name = "VarRestBackend"
  handler       = "dist/index.handler"
  role          = aws_iam_role.rest_backend_lambda_exec_role.arn
  runtime       = "nodejs20.x"

  # Assume you have packaged your Lambda function code into a ZIP file and have uploaded it to S3
  s3_bucket        = var.lambda_bucket
  s3_key           = "rest_backend/function.zip"
  source_code_hash = var.rest_backend_lambda_bundle_sha

  environment {
    variables = {
      REGION       = var.aws_region
      USER_POOL_ID = aws_cognito_user_pool.main.id
    }
  }
}

resource "aws_iam_role" "rest_backend_lambda_exec_role" {
  name = "VarRestBackendLambdaExecRole"

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

resource "aws_iam_role_policy_attachment" "rest_backend_lambda_cognito_policy_attachment" {
  role       = aws_iam_role.rest_backend_lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_cognito_policy.arn
}

resource "aws_iam_role_policy_attachment" "rest_backends_lambda_logs_attachment" {
  role       = aws_iam_role.rest_backend_lambda_exec_role.name
  policy_arn = aws_iam_policy.backend_lambda_logging_policy.arn
}

resource "aws_lambda_permission" "rest_backend_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeRestBackend"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rest_backend_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Depends on the API Gateway deployment to exist before permission is granted
  source_arn = "${aws_api_gateway_rest_api.var_rest_backend.execution_arn}/*/*"
}

resource "aws_iam_role_policy_attachment" "rest_backend_lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.rest_backend_lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

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

resource "aws_api_gateway_resource" "file_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_resource.user_files_resource.id
  path_part   = "{fileId}"
}

# API Gateway http methods
resource "aws_api_gateway_method" "get_users" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.users_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "post_user" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.users_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "get_user" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.user_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "patch_user" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.user_resource.id
  http_method   = "PATCH"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "delete_user" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.user_resource.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.var_cognito_authorizer.id
}

resource "aws_api_gateway_method" "post_file" {
  rest_api_id   = aws_api_gateway_rest_api.var_rest_backend.id
  resource_id   = aws_api_gateway_resource.user_files_resource.id
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

resource "aws_iam_policy" "backend_lambda_logging_policy" {
  name        = "VarLoggingLambdaPolicy"
  description = "Policy to allow Lambda function to handle logs"

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

resource "aws_iam_policy" "lambda_cognito_policy" {
  name        = "VarManageCognitoUsersLambdaPolicy"
  description = "Policy to allow Lambda function to manage Cognito users"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "cognito-idp:ListUsers",
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminUpdateUserAttributes",
          "cognito-idp:AdminDeleteUser"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:cognito-idp:*:*:userpool/${aws_cognito_user_pool.main.id}"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "VarManageDynamoDBLambdaPolicy"
  description = "Policy to allow Lambda function to manage DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTable",
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.main.arn
      },
      {
        Action = [
          "dynamodb:Query",
        ],
        Effect   = "Allow",
        Resource = [
          "${aws_dynamodb_table.main.arn}/index/TypeGSI",
          "${aws_dynamodb_table.main.arn}/index/DateLSI"
        ]
      }
    ]
  })
}

resource "aws_dynamodb_table" "main" {
  name         = "VarMain"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  attribute {
    name = "type"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "N"
  }

  local_secondary_index {
    name            = "DateLSI"
    range_key       = "createdAt"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "TypeGSI"
    hash_key        = "type"
    range_key       = "createdAt"
    projection_type = "ALL"
  }
}