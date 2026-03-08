output "backend_url" {

  value = aws_lb.backend_alb.dns_name
}

output "ecr_repository_url" {

  value = aws_ecr_repository.backend.repository_url
}