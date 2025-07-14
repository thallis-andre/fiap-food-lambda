resource "aws_ecr_repository" "fiap_food_identity" {
  name                 = "fiap_food_identity"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "fiap_food_identity"
  }
}

resource "aws_ecr_lifecycle_policy" "fiap_food_identity_policy" {
  repository = aws_ecr_repository.fiap_food_identity.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repository_url" {
  value = aws_ecr_repository.fiap_food_identity.repository_url
} 