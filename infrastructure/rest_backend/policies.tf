resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "VarLoggingLambdaPolicy"
  description = "Policy to allow Lambda function to handle logs"

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

resource "aws_iam_policy" "lambda_cognito_policy" {
  name        = "VarManageCognitoUsersLambdaPolicy"
  description = "Policy to allow Lambda function to manage Cognito users"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "cognito-idp:ListUsers"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:cognito-idp:*:*:userpool/${var.user_pool_id}"
      }
    ]
  })
}
