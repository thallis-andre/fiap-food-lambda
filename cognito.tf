resource "aws_cognito_user_pool" "fiap_food_identity" {
  name = "fiap-food-identity"

  alias_attributes = ["email"]

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  schema {
    name                = "role"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  schema {
    name                = "cpf"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  tags = {
    Name = "fiap-food-identity"
  }
}

resource "aws_cognito_user_pool_client" "fiap_food_identity_client" {
  name         = "fiap-food-identity-client"
  user_pool_id = aws_cognito_user_pool.fiap_food_identity.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
}

# Outputs para usar em outros recursos
output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.fiap_food_identity.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.fiap_food_identity_client.id
} 