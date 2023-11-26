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
  #     ANALYSIS_CORE_ECS_TASK_DEFINITION = aws_ecs_task_definition.analysis_core_task.arn
  #     ANALYSIS_CORE_ECS_CLUSTER         = aws_ecs_cluster.analysis_core_cluster.name
  #     ANALYSIS_CORE_SUBNET_ID_1         = aws_subnet.private_subnet_az1.id
  #     ANALYSIS_CORE_SUBNET_ID_2         = aws_subnet.private_subnet_az2.id
  #     ANALYSIS_CORE_SECURITY_GROUP      = aws_security_group.analysis_core_sg.id
  #     ANALYSIS_CORE_CONTAINER_NAME      = local.analysis_core_container_name
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
