module "backend" {

  source = "./modules/backend"

  project_name = "files-api"
}

module "frontend" {

  source = "./modules/frontend"

  project_name = var.project_name
  environment  = var.environment

  backend_url = module.backend.backend_url
}

module "lambda_daily" {

  source = "./modules/lambda_daily"

  project_name = var.project_name
  environment  = var.environment
}