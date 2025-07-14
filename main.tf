provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "fiap_food_identity" {
  function_name = "fiap_food_identity"
  image_uri     = "${var.aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/fiap_food_identity:${var.image_version}"
  role          = "arn:aws:iam::${var.aws_account_id}:role/LabRole"
  package_type  = "Image"

  timeout = 180
  environment {
    variables = {
      COGNITO_USER_POOL_ID = aws_cognito_user_pool.fiap_food_identity.id
      COGNITO_CLIENT_ID    = aws_cognito_user_pool_client.fiap_food_identity_client.id
    }
  }

  depends_on = [
    aws_cognito_user_pool.fiap_food_identity,
    aws_cognito_user_pool_client.fiap_food_identity_client
  ]
}

output "fiap_food_identity_invoke_arn" {
  description = "Function Invoke ARN"
  value       = aws_lambda_function.fiap_food_identity.invoke_arn
  sensitive   = true
}

output "fiap_food_identity_function_name" {
  description = "Function Name"
  value       = aws_lambda_function.fiap_food_identity.function_name
}
