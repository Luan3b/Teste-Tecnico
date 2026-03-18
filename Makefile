cat > Makefile << 'EOF'
.PHONY: help init plan apply destroy fmt validate test deploy-dev deploy-prod clean docker-build docker-run docker-test

SHELL := /bin/bash
PROJECT_NAME := dreamsquad-challenge

GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m 

help:
	@echo "$(GREEN)Comandos disponíveis:$(NC)"
	@echo "  $(YELLOW)make init$(NC)       - Inicializa Terraform"
	@echo "  $(YELLOW)make plan$(NC)       - Gera plano Terraform"
	@echo "  $(YELLOW)make apply$(NC)      - Aplica alterações"
	@echo "  $(YELLOW)make destroy$(NC)    - Destroi infraestrutura"
	@echo "  $(YELLOW)make fmt$(NC)        - Formata código Terraform"
	@echo "  $(YELLOW)make validate$(NC)   - Valida configuração"
	@echo "  $(YELLOW)make test$(NC)       - Roda testes automatizados"
	@echo "  $(YELLOW)make deploy-dev$(NC) - Deploy para ambiente dev"
	@echo "  $(YELLOW)make docker-build$(NC) - Build da imagem Docker"
	@echo "  $(YELLOW)make docker-run$(NC)  - Roda container local"
	@echo "  $(YELLOW)make clean$(NC)       - Limpa arquivos temporários"

init:
	@echo "$(GREEN)Initializing Terraform...$(NC)"
	cd terraform && terraform init

plan:
	@echo "$(GREEN)Generating Terraform plan...$(NC)"
	cd terraform && terraform plan

apply:
	@echo "$(GREEN)Applying Terraform changes...$(NC)"
	cd terraform && terraform apply -auto-approve

destroy:
	@echo "$(RED)Destroying infrastructure...$(NC)"
	cd terraform && terraform destroy -auto-approve

fmt:
	@echo "$(GREEN)Formatting Terraform code...$(NC)"
	cd terraform && terraform fmt -recursive

validate:
	@echo "$(GREEN)Validating Terraform configuration...$(NC)"
	cd terraform && terraform validate

test:
	@echo "$(GREEN)Running tests...$(NC)"
	pytest tests/ -v -xvs --tb=short

deploy-dev:
	@echo "$(GREEN)Deploy to DEV environment...$(NC)"
	cd terraform && terraform init && terraform apply -var="environment=dev" -auto-approve
	@echo "$(GREEN)Frontend URL: https://$$(cd terraform && terraform output -raw frontend_url)$(NC)"

deploy-prod:
	@echo "$(GREEN)Deploy to PROD environment...$(NC)"
	cd terraform && terraform init && terraform apply -var="environment=prod" -auto-approve
	@echo "$(GREEN)Frontend URL: https://$$(cd terraform && terraform output -raw frontend_url)$(NC)"

docker-build:
	@echo "$(GREEN)Building Docker image...$(NC)"
	docker build -t $(PROJECT_NAME):latest .

docker-run:
	@echo "$(GREEN)Running Docker container...$(NC)"
	docker run -p 5000:5000 \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_DEFAULT_REGION=us-east-1 \
		$(PROJECT_NAME):latest

docker-test:
	@echo "$(GREEN)Running tests in Docker...$(NC)"
	docker-compose up test --abort-on-container-exit

clean:
	@echo "$(GREEN)Cleaning temporary files...$(NC)"
	rm -rf terraform/.terraform
	rm -f terraform/*.tfstate*
	rm -f terraform/*.tfplan
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	@echo "$(GREEN)Clean complete!$(NC)"

localstack-up:
	@echo "$(GREEN)Starting LocalStack...$(NC)"
	docker-compose up localstack -d

localstack-down:
	@echo "$(GREEN)Stopping LocalStack...$(NC)"
	docker-compose down
EOF