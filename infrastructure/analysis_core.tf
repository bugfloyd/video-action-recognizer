# ECR Repo
resource "aws_ecr_repository" "analysis_core_repository" {
  name                 = "video-action-regognizer"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECR Repo retention period
resource "aws_ecr_lifecycle_policy" "analysis_core_ecr_retention_policy" {
  repository = aws_ecr_repository.analysis_core_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "analysis_core_cluster" {
  name = "analysis-core"
}

resource "aws_cloudwatch_log_group" "analysis_core_ecs_log_group" {
  name = "/ecs/analysis-core"
}


# Task Definition
resource "aws_ecs_task_definition" "analysis_core_task" {
  family                   = "analysis-core"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.analysis_core_ecs_task_role.arn
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode([
    {
      name  = local.analysis_core_container_name
      image = "${aws_ecr_repository.analysis_core_repository.repository_url}:latest"
      environment = [
        {
          name  = "INPUT_VIDEO_S3_BUCKET",
          value = aws_s3_bucket.input_bucket.id
        },
        {
          name  = "INPUT_VIDEO_S3_KEY",
          value = ""
        },
        {
          name  = "S3_REGION",
          value = var.aws_region
        },
        {
          name  = "OUTPUT_VIDEO_S3_BUCKET",
          value = aws_s3_bucket.output_bucket.id
        },
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.analysis_core_ecs_log_group.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# Execution Role: Used by ECS while running a task 
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_execution_role_default_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Role: Applied to task containers
resource "aws_iam_role" "analysis_core_ecs_task_role" {
  name = "analysis_core_ecs_task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
      },
    ],
  })
}
resource "aws_iam_policy" "analysis_core_s3_access" {
  name = "analysis_core_s3_access_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.input_bucket}/*"
      },
      {
        Action   = "s3:PutObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.output_bucket}/*"
      },
    ],
  })
}
resource "aws_iam_role_policy_attachment" "analysis_core_s3_access_attachment" {
  role       = aws_iam_role.analysis_core_ecs_task_role.name
  policy_arn = aws_iam_policy.analysis_core_s3_access.arn
}
