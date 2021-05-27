output "registry_name" {
  value       = aws_ecr_repository.ecr-repository.name
  description = "Name of the repository"
}

output "registry_id" {
  value       = aws_ecr_repository.ecr-repository.registry_id
  description = "Registry ID where the repository was created"
}

output "repository_url" {
  value       = aws_ecr_repository.ecr-repository.repository_url
  description = "URL of the repository"
}

output "arn" {
  value       = aws_ecr_repository.ecr-repository.arn
  description = "Full ARN of the repository"
}