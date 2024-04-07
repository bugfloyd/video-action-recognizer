resource "aws_lambda_function" "upload_listener_lambda" {
  function_name = "UploadListener"
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
      DESTINATION_BUCKET_NAME           = aws_s3_bucket.data_bucket.id
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

resource "aws_iam_policy" "listener_lambda_s3_policy" {
  name = "listener_lambda_s3_policy"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Effect": "Allow",
        "Action": [
          "s3:HeadObject",
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "s3:DeleteObject"
        ],
        "Resource": [
          "${aws_s3_bucket.input_bucket.arn}/*",
          "${aws_s3_bucket.data_bucket.arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": [
          aws_s3_bucket.input_bucket.arn,
          aws_s3_bucket.data_bucket.arn,
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attachment" {
  role       = aws_iam_role.upload_listener_lambda_exec_role.name
  policy_arn = aws_iam_policy.listener_lambda_logging_policy.arn
}
resource "aws_iam_role_policy_attachment" "listener_lambda_s3_copy" {
  role       = aws_iam_role.upload_listener_lambda_exec_role.name
  policy_arn = aws_iam_policy.listener_lambda_s3_policy.arn
}

resource "aws_lambda_permission" "upload_listener_allow_event_bridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_listener_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_event_rule.arn
}

resource "aws_cloudwatch_event_rule" "s3_event_rule" {
  name = "FileUploaded"
  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [aws_s3_bucket.input_bucket.bucket]
      }
      "object" : {
        "key" : [{
          "prefix" : "upload/"
        }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "PreProcessUploadedFileLambda" {
  rule = aws_cloudwatch_event_rule.s3_event_rule.name
  arn  = aws_lambda_function.upload_listener_lambda.arn
}