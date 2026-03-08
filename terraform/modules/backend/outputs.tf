output "backend_url" {
  value = aws_lb.backend_alb.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "backend_api_url" {
  value = "http://${aws_lb.backend_alb.dns_name}/files"
}
