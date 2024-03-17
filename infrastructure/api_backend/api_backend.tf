resource "aws_lambda_function" "rest_backend_lambda" {
  function_name = "VarRestBackend"
  handler       = "dist/index.handler"
  role          = aws_iam_role.rest_backend_lambda_exec_role.arn
  runtime       = "nodejs20.x"

  # Assume you have packaged your Lambda function code into a ZIP file and have uploaded it to S3
  s3_bucket        = var.lambda_bucket
  s3_key           = "rest_backend/function.zip"
  source_code_hash = var.rest_backend_lambda_bundle_sha

  vpc_config {
    subnet_ids         = [var.private_subnet_id_az1, var.private_subnet_id_az2]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      REGION       = var.aws_region
      USER_POOL_ID = aws_cognito_user_pool.main.id
      DB_ENDPOINT  = aws_db_proxy.var_db_proxy.endpoint
      DB_USER      = var.db_user
      DB_PORT      = aws_rds_cluster.aurora_serverless_cluster.port
    }
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LambdaSG"
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
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.rest_backend_lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
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
      }
    ]
  })
}

resource "aws_rds_cluster" "aurora_serverless_cluster" {
  cluster_identifier = "var-aurora-cluster1"
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned" # Use "provisioned" for Serverless v2
  engine_version     = "15.4"
  database_name      = "varmain"
  master_username    = var.db_user
  #  master_password      = var.db_password
  manage_master_user_password = true
  skip_final_snapshot         = true # Enable for production
  db_subnet_group_name        = aws_db_subnet_group.aurora_subnet_group.name
  serverlessv2_scaling_configuration {
    min_capacity = 0.5 # Minimum ACU. The smallest increment is 0.5 ACU for Serverless v2.
    max_capacity = 2   # Maximum ACU. Adjust based on expected peak load in dev environment.
  }
  vpc_security_group_ids = [aws_security_group.rds_cluster_sg.id]
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  engine             = "aurora-postgresql"
  cluster_identifier = aws_rds_cluster.aurora_serverless_cluster.cluster_identifier
  instance_class     = "db.serverless"
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [var.private_subnet_id_az1, var.private_subnet_id_az2]

  tags = {
    Name = "VAR Aurora Subnet Group"
  }
}

resource "aws_db_proxy" "var_db_proxy" {
  name           = "var-db-proxy"
  engine_family  = "POSTGRESQL"
  role_arn       = aws_iam_role.db_proxy_role.arn
  vpc_subnet_ids = [var.private_subnet_id_az1, var.private_subnet_id_az2]
  require_tls    = true # Set to true if you want to enforce TLS

  auth {
    auth_scheme = "SECRETS"
    description = "Authentication used for the DB proxy"
    iam_auth    = "REQUIRED"
    secret_arn  = aws_rds_cluster.aurora_serverless_cluster.master_user_secret[0].secret_arn
  }

  idle_client_timeout    = 1800  # Adjust based on your needs
  debug_logging          = false # Set to true if you need detailed logs for troubleshooting
  vpc_security_group_ids = [aws_security_group.rds_proxy_sg.id]

  tags = {
    Name = "var-db-proxy"
  }
}

resource "aws_iam_role" "db_proxy_role" {
  name = "var-db-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "rds.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "db_proxy_policy" {
  name        = "var-db-proxy-policy"
  description = "A policy for the DB proxy to access secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Effect   = "Allow"
      Resource = aws_rds_cluster.aurora_serverless_cluster.master_user_secret[0].secret_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "db_proxy_policy_attachment" {
  role       = aws_iam_role.db_proxy_role.name
  policy_arn = aws_iam_policy.db_proxy_policy.arn
}

resource "aws_db_proxy_default_target_group" "main" {
  db_proxy_name = aws_db_proxy.var_db_proxy.name

  connection_pool_config {
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    connection_borrow_timeout    = 120
    session_pinning_filters      = ["EXCLUDE_VARIABLE_SETS"]
  }
}

resource "aws_db_proxy_target" "main" {
  db_proxy_name         = aws_db_proxy.var_db_proxy.name
  target_group_name     = "default"
  db_cluster_identifier = aws_rds_cluster.aurora_serverless_cluster.id # For an Aurora cluster
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_policy" "lambda_db_proxy_policy" {
  name        = "LambdaDBProxyPolicy"
  description = "Allow Lambda functions to access RDS Proxy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds-db:connect"
        ],
        Resource = [
          "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_proxy.var_db_proxy.id}/${var.db_user}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_db_proxy_attach" {
  role       = aws_iam_role.rest_backend_lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_db_proxy_policy.arn
}

resource "aws_security_group" "rds_cluster_sg" {
  name        = "rds-cluster-sg"
  description = "Security group for RDS cluster that only allows traffic from the RDS Proxy"
  vpc_id      = var.vpc_id

  # Allow inbound traffic from RDS Proxy's security group
  ingress {
    description     = "Allow inbound traffic from RDS Proxy"
    from_port       = 5432 # the database port
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_proxy_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDSClusterSG"
  }
}

resource "aws_security_group" "rds_proxy_sg" {
  name        = "rds-proxy-sg"
  description = "Security group for RDS Proxy"
  vpc_id      = var.vpc_id

  # Allow inbound traffic on the database port from a specific source, such as
  # another security group (e.g., your application servers or Lambda functions)
  ingress {
    description = "Allow inbound traffic to RDS Proxy from App Servers"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # For simplicity, this example allows traffic from any source in the VPC.
    # Replace "0.0.0.0/0" with specific CIDR blocks or reference another security
    # group if you want to restrict access further.
    #    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDSProxySG"
  }
}
