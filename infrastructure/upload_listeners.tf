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
      DESTINATION_BUCKET_NAME = aws_s3_bucket.data_bucket.id
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
        "Effect" : "Allow",
        "Action" : [
          "s3:HeadObject",
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "${aws_s3_bucket.input_bucket.arn}/*",
          "${aws_s3_bucket.data_bucket.arn}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
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

resource "aws_cloudwatch_event_rule" "s3_file_uploaded_event_rule" {
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
  rule = aws_cloudwatch_event_rule.s3_file_uploaded_event_rule.name
  arn  = aws_lambda_function.upload_listener_lambda.arn
}

resource "aws_lambda_permission" "upload_listener_allow_event_bridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_listener_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_file_uploaded_event_rule.arn
}

# IAM role for the EventBridge to run analysis task
resource "aws_iam_role" "eventbridge_run_analysis_ecs_role" {
  name = "EventBridgeRunAnalysisEcsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "eventbridge_run_ecs_task_policy" {
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
        ],
        Condition : {
          StringEquals : {
            "iam:PassedToService" : ["ecs-tasks.amazonaws.com"]
          }
        }
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

resource "aws_iam_role_policy_attachment" "eventbridge_run_analysis_attachment" {
  role       = aws_iam_role.eventbridge_run_analysis_ecs_role.name
  policy_arn = aws_iam_policy.eventbridge_run_ecs_task_policy.arn
}

resource "aws_cloudwatch_event_rule" "s3_file_copied_event_rule" {
  name = "FileCopied"
  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [aws_s3_bucket.data_bucket.bucket]
      }
      "object" : {
        "key" : [{
          "prefix" : "files/"
        }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "AnalyzeVideoECSTask" {
  rule     = aws_cloudwatch_event_rule.s3_file_copied_event_rule.name
  arn      = aws_ecs_cluster.analysis_core_cluster.arn
  role_arn = aws_iam_role.eventbridge_run_analysis_ecs_role.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.analysis_core_task.arn
    task_count          = 1
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
      assign_public_ip = false
      security_groups = [aws_security_group.analysis_core_sg.id]
    }
  }

  input_transformer {
    input_paths = {
      objectKey : "$.detail.object.key"
    }
    input_template = <<EOF
{
  "containerOverrides": [
    {
      "name": "${local.analysis_core_container_name}",
      "environment": [
        {
          "name": "INPUT_VIDEO_S3_KEY",
          "value": "<objectKey>"
        }
      ]
    }
  ]
}
EOF
  }
}