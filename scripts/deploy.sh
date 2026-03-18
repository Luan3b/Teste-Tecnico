#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}

echo -e "${YELLOW}=== Deploy DreamSquad - Ambiente: $ENVIRONMENT ===${NC}"

cd terraform

echo -e "${GREEN}Inicializando Terraform...${NC}"
terraform init \
  -backend-config="bucket=dreamsquad-terraform-state-$ENVIRONMENT" \
  -backend-config="key=$ENVIRONMENT/terraform.tfstate" \
  -backend-config="region=us-east-1"

echo -e "${GREEN}Formatando código...${NC}"
terraform fmt -recursive

echo -e "${GREEN}Validando configuração...${NC}"
terraform validate

if [ "$ACTION" = "plan" ]; then
    echo -e "${GREEN}Gerando plano...${NC}"
    terraform plan -var="environment=$ENVIRONMENT"
    
elif [ "$ACTION" = "apply" ]; then
    echo -e "${GREEN}Aplicando alterações...${NC}"
    terraform apply -var="environment=$ENVIRONMENT" -auto-approve
    
    echo -e "${GREEN}Outputs:${NC}"
    terraform output
    
    FRONTEND_URL=$(terraform output -raw frontend_url 2>/dev/null || echo "Não disponível")
    echo -e "${GREEN}Frontend URL: https://$FRONTEND_URL${NC}"
    
elif [ "$ACTION" = "destroy" ]; then
    echo -e "${RED}ATENÇÃO: Isso vai destruir toda a infraestrutura!${NC}"
    read -p "Digite 'destroy' para confirmar: " confirm
    
    if [ "$confirm" = "destroy" ]; then
        terraform destroy -var="environment=$ENVIRONMENT" -auto-approve
    else
        echo -e "${YELLOW}Operação cancelada${NC}"
    fi
fi

cd ..
