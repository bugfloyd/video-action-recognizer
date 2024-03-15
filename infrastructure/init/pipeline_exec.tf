# Create an IAM OIDC identity provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}

# Create an IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"
  count = var.github_repo != "" ? 1 : 0

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com",
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })
}

# Attach policies to the IAM role as needed
# Example: attaching a read-only policy
resource "aws_iam_role_policy_attachment" "administrator_access" {
  count = length(aws_iam_role.github_actions)
  role       = aws_iam_role.github_actions[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "pipeline_execution_role_arn" {
  value = length(aws_iam_role.github_actions) > 0 ? aws_iam_role.github_actions[0].arn : "NO GITHUB REPO PROVIDED"
}
