provider "aws" {
  region = "us-east-1"
}

# Role IAM para a Lambda Function
resource "aws_iam_role" "lambda_execution_role" {
  name = "fiap_food_identity_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "fiap_food_identity_lambda_role"
  }
}

# Política de execução básica para Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política personalizada para acessar Cognito
resource "aws_iam_policy" "cognito_access_policy" {
  name        = "fiap_food_identity_cognito_policy"
  description = "Policy for Lambda to access Cognito"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminUpdateUserAttributes",
          "cognito-idp:AdminDeleteUser",
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:AdminRespondToAuthChallenge",
          "cognito-idp:AdminSetUserPassword",
          "cognito-idp:AdminConfirmSignUp",
          "cognito-idp:AdminGetUser",
          "cognito-idp:ListUsers"
        ]
        Resource = aws_cognito_user_pool.fiap_food_identity.arn
      }
    ]
  })
}

# Anexar política do Cognito ao role
resource "aws_iam_role_policy_attachment" "lambda_cognito_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.cognito_access_policy.arn
}

resource "aws_lambda_function" "fiap_food_identity" {
  function_name = "fiap_food_identity"
  image_uri     = "${var.aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/fiap_food_identity:${var.image_version}"
  role          = aws_iam_role.lambda_execution_role.arn
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
    aws_cognito_user_pool_client.fiap_food_identity_client,
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_cognito_access
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

output "lambda_execution_role_arn" {
  description = "Lambda Execution Role ARN"
  value       = aws_iam_role.lambda_execution_role.arn
}
