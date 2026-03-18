variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "github_connection_arn" {
  description = "ARN da conexão do CodeStar com GitHub"
  type        = string
}

variable "github_repo" {
  description = "Repositório GitHub (formato: owner/repo)"
  type        = string
}

variable "github_branch" {
  description = "Branch do GitHub"
  type        = string
  default     = "main"
}