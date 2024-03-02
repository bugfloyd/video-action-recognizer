resource "aws_lambda_function" "upload_listener_lambda" {
  function_name = "analysis_core_task_trigger"
  handler       = "listener_lambda.lambda_handler"
  role          = aws_iam_role.upload_listener_lambda_exec_role.arn
  runtime       = "python3.9"

  # Assume you have packaged your Lambda function code into a ZIP file and have uploaded it to S3
  s3_bucket        = var.lambda_bucket
  s3_key           = "upload_listener/latest/function.zip"
  source_code_hash = var.upload_listener_lambda_bundle_sha

  environment {
    variables = {
      ANALYSIS_CORE_ECS_TASK_DEFINITION = aws_ecs_task_definition.analysis_core_task.arn
      ANALYSIS_CORE_ECS_CLUSTER         = aws_ecs_cluster.analysis_core_cluster.name
      ANALYSIS_CORE_SUBNET_ID_1         = aws_subnet.private_subnet_az1.id
      ANALYSIS_CORE_SUBNET_ID_2         = aws_subnet.private_subnet_az2.id
      ANALYSIS_CORE_SECURITY_GROUP      = aws_security_group.analysis_core_sg.id
      ANALYSIS_CORE_CONTAINER_NAME      = local.analysis_core_container_name
    }
  }
}

# IAM role for the Lambda function
resource "aws_iam_role" "upload_listener_lambda_exec_role" {
  name = "upload_listener_lambda_exec_role"

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

resource "aws_iam_policy" "listener_lambda_logging_policy" {
  name = "listener_lambda_logging_policy"
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

resource "aws_iam_policy" "lambda_run_ecs_task_policy" {
  name = "lambda_run_ecs_task_policy"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "IAMPassRolePolicy"
        Effect : "Allow",
        Action : [
          "iam:PassRole",
        ],
        Resource : [
          aws_iam_role.ecs_execution_role.arn,
          aws_iam_role.analysis_core_ecs_task_role.arn
        ]
      },
      {
        Sid : "EcsRunAnalysisCoreTaskPolicy"
        Effect : "Allow",
        Action : [
          "ecs:RunTask",
        ],
        Resource : [
          aws_ecs_task_definition.analysis_core_task.arn,
          aws_ecs_cluster.analysis_core_cluster.arn
        ]
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_logs_attachment" {
  role       = aws_iam_role.upload_listener_lambda_exec_role.name
  policy_arn = aws_iam_policy.listener_lambda_logging_policy.arn
}
resource "aws_iam_role_policy_attachment" "lambda_ecs_task_run_attachment" {
  role       = aws_iam_role.upload_listener_lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_run_ecs_task_policy.arn
}


# Lambda function permissions to be triggered by S3
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_listener_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.input_bucket.id}"
}

# Trigger Lambda function on S3 put events for mp4 and gif files
resource "aws_s3_bucket_notification" "input_bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.upload_listener_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".mp4"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.upload_listener_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".gif"
  }
}
