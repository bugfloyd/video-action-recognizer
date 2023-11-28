resource "aws_lambda_function" "upload_request_lambda" {
  function_name = "var_upload_request"
  handler       = "dist/index.handler"
  role          = aws_iam_role.upload_request_lambda_exec_role.arn
  runtime       = "nodejs18.x"

  # Assume you have packaged your Lambda function code into a ZIP file and have uploaded it to S3
  s3_bucket        = var.lambda_bucket
  s3_key           = "uploader/latest/function.zip"
  source_code_hash = var.upload_request_lambda_bundle_sha

  # environment {
  #   variables = {
  #     AENV_VAR_NAME = "VAR_VALUE"
  #   }
  # }
}

# IAM role for the Lambda function
resource "aws_iam_role" "upload_request_lambda_exec_role" {
  name = "upload_request_lambda_exec_role"

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

resource "aws_iam_policy" "upload_request_lambda_logging_policy" {
  name = "upload_request_lambda_logging_policy"
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

resource "aws_iam_policy" "upload_request_lambda_task_policy" {
  name = "upload_request_lambda_task_policy"
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
resource "aws_iam_role_policy_attachment" "upload_request_lambda_logs_attachment" {
  role       = aws_iam_role.upload_request_lambda_exec_role.name
  policy_arn = aws_iam_policy.upload_request_lambda_logging_policy.arn
}
resource "aws_iam_role_policy_attachment" "upload_request_lambda_task_attachment" {
  role       = aws_iam_role.upload_request_lambda_exec_role.name
  policy_arn = aws_iam_policy.upload_request_lambda_task_policy.arn
}

resource "aws_lambda_permission" "api_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_request_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Depends on the API Gateway deployment to exist before permission is granted
  source_arn = var.api_gateway_execution_arn
}

resource "aws_api_gateway_integration" "upload_request_lambda_integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = var.api_resource_id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.upload_request_lambda.invoke_arn
}
