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
      DB_ENDPOINT = aws_rds_cluster.aurora_serverless_cluster.endpoint
      DB_USER = var.db_user
      DB_PORT = aws_rds_cluster.aurora_serverless_cluster.port
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

# IAM role policy attachments
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

# API Gateway resources
resource "aws_api_gateway_resource" "users_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_rest_api.var_rest_backend.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_resource" "user_resource" {
  rest_api_id = aws_api_gateway_rest_api.var_rest_backend.id
  parent_id   = aws_api_gateway_resource.users_resource.id
  path_part   = "{user_id}"
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
      },
      {
        Action = [
          "rds-data:*"
        ],
        Effect   = "Allow",
        Resource = aws_rds_cluster.aurora_serverless_cluster.arn
      }
    ]
  })
}

resource "aws_rds_cluster" "aurora_serverless_cluster" {
  cluster_identifier   = "var-aurora-cluster1"
  engine               = "aurora-postgresql"
#  engine_mode          = "provisioned" # Use "provisioned" for Serverless v2
  engine_version       = "15.4"
  database_name        = "varmain"
  master_username      = var.db_user
#  master_password      = var.db_password
  manage_master_user_password = true
  skip_final_snapshot  = true # Enable for production
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  serverlessv2_scaling_configuration {
    min_capacity = 0.5 # Minimum ACU. The smallest increment is 0.5 ACU for Serverless v2.
    max_capacity = 2 # Maximum ACU. Adjust based on expected peak load in dev environment.
  }
  #  vpc_security_group_ids = [] # ToDo
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  engine = "aurora-postgresql"
  cluster_identifier = aws_rds_cluster.aurora_serverless_cluster.cluster_identifier
  instance_class     = "db.serverless"
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]

  tags = {
    Name = "VAR Aurora Subnet Group"
  }
}