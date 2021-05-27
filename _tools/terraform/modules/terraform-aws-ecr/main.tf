resource "aws_ecr_repository" "ecr-repository" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = var.repository_name
    Service     = var.service
    Role        = var.role
    Environment = var.env
  }
}

resource "aws_ecr_lifecycle_policy" "old-and-untagged-img-policy" {
  repository = aws_ecr_repository.ecr-repository.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Remove untagged images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Rotate images when reach ${var.max_image_count} images stored",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": ${var.max_image_count}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

resource "aws_ecr_repository_policy" "authorize-eks" {
  repository = aws_ecr_repository.ecr-repository.name
  policy     = data.aws_iam_policy_document.authorize-eks-policy.json
}

data "aws_iam_policy_document" "authorize-eks-policy" {
  statement {
    sid    = "allow-access-ecr-from-eks"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages"
    ]
    principals {
      type        = "AWS"
      identifiers = var.authorized_eks_clusters_arn
    }
  }
}