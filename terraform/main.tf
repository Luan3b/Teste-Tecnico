module "frontend" {
  source = "./modules/frontend"

  project_name = var.project_name
  environment  = var.environment
}

module "backend" {
  source = "./modules/backend"

  project_name = var.project_name
  environment  = var.environment
}

module "lambda_daily" {
  source = "./modules/lambda_daily"

  project_name = var.project_name
  environment  = var.environment
}