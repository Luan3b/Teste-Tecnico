output "frontend_url" {
  description = "CloudFront URL for the frontend"
  value       = "https://${module.frontend.frontend_url}"
}

output "backend_url" {
  description = "ALB URL for the backend"
  value       = "http://${module.backend.backend_url}"
}

output "backend_api_url" {
  description = "Backend API endpoint"
  value       = module.backend.backend_api_url
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.backend.ecr_repository_url
}

output "scheduler_bucket_name" {
  description = "S3 bucket for daily scheduled files"
  value       = module.lambda_daily.scheduler_bucket_name
}

output "lambda_daily_name" {
  description = "Daily lambda function name"
  value       = module.lambda_daily.lambda_name
}