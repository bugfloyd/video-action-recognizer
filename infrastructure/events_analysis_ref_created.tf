resource "aws_cloudwatch_event_rule" "analysis_ref_created" {
  name           = "AnalysisRefCreated"
  event_bus_name = aws_cloudwatch_event_bus.var_bus.name
  event_pattern = jsonencode({
    "source" : ["var.backend"],
    "detail-type" : ["AnalysisRefCreated"],
  })
}

resource "aws_cloudwatch_event_target" "analysis_ref_created" {
  rule           = aws_cloudwatch_event_rule.analysis_ref_created.name
  event_bus_name = aws_cloudwatch_event_bus.var_bus.name
  target_id      = "RunVideoAnalysisECSTask"
  arn            = aws_ecs_cluster.analysis_core_cluster.arn
  role_arn       = aws_iam_role.eventbridge_run_analysis_ecs_role.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.analysis_core_task.arn
    task_count          = 1
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
      assign_public_ip = false
      security_groups  = [aws_security_group.analysis_core_sg.id]
    }
  }

  input_transformer {
    input_paths = {
      fileKey : "$.detail.file.key"
    }
    input_template = <<EOF
{
  "containerOverrides": [
    {
      "name": "${local.analysis_core_container_name}",
      "environment": [
        {
          "name": "INPUT_VIDEO_S3_KEY",
          "value": "<fileKey>"
        }
      ]
    }
  ]
}
EOF
  }
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