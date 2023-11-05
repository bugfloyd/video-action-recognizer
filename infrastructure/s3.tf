resource "aws_s3_bucket" "input_bucket" {
  bucket = var.input_bucket
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = var.output_bucket
}

resource "aws_s3_bucket_policy" "input_bucket_policy" {
  bucket = aws_s3_bucket.input_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { "AWS" : aws_iam_role.analysis_core_ecs_task_role.arn },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.input_bucket.arn}/*"
      },
    ],
  })
}

resource "aws_s3_bucket_policy" "output_bucket_policy" {
  bucket = aws_s3_bucket.output_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { "AWS" : aws_iam_role.analysis_core_ecs_task_role.arn },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.output_bucket.arn}/*"
      },
    ],
  })
}
