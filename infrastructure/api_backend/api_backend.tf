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
      REGION                             = var.aws_region
      USER_POOL_ID                       = aws_cognito_user_pool.main.id
      CLOUDFRONT_DISTRIBUTION_DOMAIN     = var.cloudfront_distribution_domain
      CLOUDFRONT_PRIVATE_KEY_SECRET_NAME = var.cloudfront_private_key_secret_arn
      CLOUDFRONT_PUBLIC_KEY_ID           = var.cloudfront_public_key_id
      EVENT_BUS_NAME                     = var.event_bus_name
    }
  }
}

output "rest_backend_lambda_arn" {
  value = aws_lambda_function.rest_backend_lambda.arn
}

output "rest_backend_lambda_name" {
  value = aws_lambda_function.rest_backend_lambda.function_name
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

output "rest_backend_lambda_exec_role_name" {
  value = aws_iam_role.rest_backend_lambda_exec_role.name
}

resource "aws_iam_role_policy_attachment" "rest_backend_lambda_cognito_policy_attachment" {
  role       = aws_iam_role.rest_backend_lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_cognito_policy.arn
}

resource "aws_iam_role_policy_attachment" "rest_backends_lambda_logs_attachment" {
  role       = aws_iam_role.rest_backend_lambda_exec_role.name
  policy_arn = aws_iam_policy.backend_lambda_logging_policy.arn
}

resource "aws_lambda_permission" "rest_backend_lambda_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvokeRestBackend"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rest_backend_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.var_rest_backend.execution_arn}/*/*"
}

resource "aws_iam_role_policy_attachment" "rest_backend_lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.rest_backend_lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "allow_put_events" {
  role       = aws_iam_role.rest_backend_lambda_exec_role.name
  policy_arn = aws_iam_policy.allow_put_events.arn
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
        Resource : "arn:aws:logs:*:*:*" // TODO
      }
    ]
  })
}

resource "aws_iam_policy" "allow_put_events" {
  name = "backend_lambda_events_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "events:PutEvents",
        "Resource" : var.event_bus_arn
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
        Effect = "Allow",
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