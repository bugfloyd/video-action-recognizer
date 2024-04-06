# IAM policy to allow the Lambda function to access the Secrets
resource "aws_iam_policy" "lambda_secrets_access" {
  name        = "lambda_secrets_access"
  description = "Allows Lambda function to access CloudFront keys in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = ["secretsmanager:GetSecretValue"],
      Resource = [
        var.cloudfront_private_key_arn
      ],
      Effect = "Allow",
    }]
  })
}

# Attach the policy to backend Lambda function's role
resource "aws_iam_role_policy_attachment" "lambda_secrets_access_attachment" {
  role       = module.api_backend.rest_backend_lambda_exec_role_name
  policy_arn = aws_iam_policy.lambda_secrets_access.arn
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "S3 Distribution for files"
  default_root_object = "index.html"
  # aliases = ["yourdomain.example.com"]
  price_class = "PriceClass_All"

  origin {
    domain_name = aws_s3_bucket.input_bucket.bucket_domain_name
    origin_id   = "S3-${aws_s3_bucket.input_bucket.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_input_oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_s3_bucket.data_bucket.bucket_domain_name
    origin_id   = "S3-${aws_s3_bucket.data_bucket.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_data_oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.data_bucket.id}"
    trusted_key_groups = [aws_cloudfront_key_group.main_key_group.id]
    cache_policy_id = aws_cloudfront_cache_policy.user_data.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.user_data.id
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "PUT", "POST", "PATCH", "OPTIONS", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.input_bucket.id}"
    trusted_key_groups = [aws_cloudfront_key_group.main_key_group.id]
    cache_policy_id = aws_cloudfront_cache_policy.user_data.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.user_data.id
    viewer_protocol_policy = "redirect-to-https"
    path_pattern = "/upload/*"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_cache_policy" "user_data" {
  name        = "no-cache-user-data"
  default_ttl = 0
  max_ttl     = 0
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_brotli = false
    enable_accept_encoding_gzip = false
  }
}

resource "aws_cloudfront_origin_request_policy" "user_data" {
  name    = "no-pass-user-data"
  cookies_config {
    cookie_behavior = "none"
  }
  headers_config {
    header_behavior = "none"
  }
  query_strings_config {
    query_string_behavior = "none"
  }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

resource "aws_cloudfront_origin_access_identity" "s3_input_oai" {
  comment = "OAI for S3 input bucket access"
}

resource "aws_cloudfront_origin_access_identity" "s3_data_oai" {
  comment = "OAI for S3 data bucket access"
}

data "aws_secretsmanager_secret" "cloudfront_key_id" {
  arn = var.cloudfront_key_id_arn
}
data "aws_secretsmanager_secret_version" "cloudfront_key_id_current" {
  secret_id = data.aws_secretsmanager_secret.cloudfront_key_id.id
}

resource "aws_cloudfront_public_key" "main" {
  encoded_key = data.aws_secretsmanager_secret_version.cloudfront_key_id_current.secret_string
  name        = "var_signing_private_key"

  lifecycle {
    ignore_changes = [encoded_key]
  }
}

resource "aws_cloudfront_key_group" "main_key_group" {
  name    = "main-key-group"
  items   = [aws_cloudfront_public_key.main.id]
  comment = "Key group for CloudFront signed URLs"
}