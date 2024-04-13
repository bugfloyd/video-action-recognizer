resource "aws_cognito_user_pool" "main" {
  name = "var-user-pool"

  password_policy {
    minimum_length                   = 8
    require_numbers                  = true
    require_lowercase                = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  auto_verified_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  schema {
    attribute_data_type      = "String"
    name                     = "given_name"
    required                 = true
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 2
      max_length = 50
    }
  }

  schema {
    attribute_data_type      = "String"
    name                     = "family_name"
    mutable                  = true
    required                 = false
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 2
      max_length = 50
    }
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  username_attributes = ["email"]
  username_configuration {
    case_sensitive = false
  }
  mfa_configuration = "OFF"
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_resource_server" "main_backend" {
  user_pool_id = aws_cognito_user_pool.main.id
  identifier   = "https://var.bugfloyd.com"
  name         = "VAR backend"
  scope {
    scope_description = "Allow user to use VAR"
    scope_name        = "use:var"
  }
}


resource "aws_cognito_user_pool_client" "main" {
  name                                 = "Video Action Recognizer"
  user_pool_id                         = aws_cognito_user_pool.main.id
  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile", "https://var.bugfloyd.com/use:var"]
  callback_urls                        = ["http://localhost"]
  logout_urls                          = ["http://localhost"]
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  supported_identity_providers = ["COGNITO"]
  access_token_validity = 24
  id_token_validity = 24
  prevent_user_existence_errors = "ENABLED"
}

# Create Admin Group in Cognito
resource "aws_cognito_user_group" "admin_group" {
  name         = "Admins"
  user_pool_id = aws_cognito_user_pool.main.id
  precedence   = 1
}

# Create User Group in Cognito
resource "aws_cognito_user_group" "user_group" {
  name         = "Users"
  user_pool_id = aws_cognito_user_pool.main.id
  precedence   = 2
}

# resource "aws_cognito_identity_provider" "google" {
#   user_pool_id  = aws_cognito_user_pool.main.id
#   provider_name = "Google"
#   provider_type = "Google"

#   provider_details = {
#     # The following details need to be configured with Google's credentials.
#     # "authorize_scopes" : "openid profile email",
#     # "client_id"        : "your-app-client-id",
#     # "client_secret"    : "your-app-client-secret",
#   }

#   attribute_mapping = {
#     # Map the Google user account fields to the Amazon Cognito user pool attributes.
#     "email"      = "email",
#     "given_name" = "given_name",
#   }
# }

# Output the Cognito User Pool ID and Cognito User Pool Client ID
output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.main.id
}

output "cognito_user_pool_domain" {
  value = "${aws_cognito_user_pool_domain.main.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "cognito_user_pool_resource_server_identifier" {
  value = aws_cognito_resource_server.main_backend.identifier
}
