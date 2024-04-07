resource "aws_s3_bucket" "input_bucket" {
  bucket = var.input_bucket
}

resource "aws_s3_bucket_notification" "input_bucket_notifications" {
  bucket      = aws_s3_bucket.input_bucket.bucket
  eventbridge = true
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = var.data_bucket
}

resource "aws_s3_bucket_notification" "data_bucket_notifications" {
  bucket      = aws_s3_bucket.data_bucket.bucket
  eventbridge = true
}

resource "aws_s3_bucket_policy" "input_bucket_policy" {
  bucket = aws_s3_bucket.input_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "EnforceHTTPS",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource = [
          "${aws_s3_bucket.input_bucket.arn}/*",
          aws_s3_bucket.input_bucket.arn,
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" : "false"
          }
        }
      },
      {
        Sid       = "AllowCloudFrontUpload",
        Action    = ["s3:PutObject"],
        Effect    = "Allow",
        Principal = { "AWS" : "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.s3_input_oai.id}" },
        Resource  = "${aws_s3_bucket.input_bucket.arn}/*",
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "data_bucket_policy" {
  bucket = aws_s3_bucket.data_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowAnalysisAccess"
        Effect    = "Allow",
        Principal = { "AWS" : aws_iam_role.analysis_core_ecs_task_role.arn },
        Action    = ["s3:GetObject", "s3:PutObject"],
        Resource  = "${aws_s3_bucket.data_bucket.arn}/*"
      },
      {
        Sid       = "AllowCloudFrontRead",
        Action    = ["s3:GetObject"],
        Effect    = "Allow",
        Principal = { "AWS" : "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.s3_data_oai.id}" },
        Resource  = "${aws_s3_bucket.data_bucket.arn}/*",
      },
    ],
  })
}

resource "aws_s3_bucket_public_access_block" "upload_bucket_access_block" {
  bucket = aws_s3_bucket.input_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "data_bucket_access_block" {
  bucket = aws_s3_bucket.data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
