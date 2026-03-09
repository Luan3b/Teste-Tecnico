Este é um projeto Infrastructure as Code (IaC) utilizando Terraform para deploy de uma aplicação serverless na AWS. O sistema consiste em:

Backend ECS Fargate (API Flask)

Frontend S3 + CloudFront (Site estático)

Lambda Agendada (Geração automática de arquivos)

Toda infraestrutura de rede necessária

dreamsquad-challenge/
├── main.tf                  # Orquestração dos módulos

├── provider.tf              # Configuração do AWS Provider

├── variables.tf             # Variáveis globais

├── versions.tf              # Versões dos providers

├── outputs.tf               # Outputs globais

│
├── modules/

│   ├── backend/             # Módulo da API Flask

│   │   ├── main.tf          # VPC, ECS, ALB, ECR

│   │   ├── outputs.tf       # URL do backend

│   │   ├── variables.tf     # project_name

│   │   ├── app.py           # Código Flask

│   │   └── requirements.txt # Dependências Python

│   │

│   ├── frontend/            # Módulo do site estático

│   │   ├── main.tf          # S3 + CloudFront

│   │   ├── outputs.tf       # URL do frontend

│   │   ├── variables.tf     # project_name, environment, backend_url

│   │   ├── index.html.tpl   # Template HTML (com variável backend_url)

│   │   └── style.css        # Estilos CSS

│   │

│   └── lambda_daily/        # Módulo da Lambda agendada

│       ├── main.tf          # Lambda + S3 + EventBridge

│       ├── outputs.tf       # Nome do bucket e lambda

│       ├── variables.tf     # project_name, environment

│       └── lambda/

│           └── handler.py   # Código Python da Lambda


🔧 CONFIGURAÇÃO INICIAL

Configure suas credenciais AWS

aws configure
# Coloque sua Access Key ID
# Coloque sua Secret Access Key
# Região: us-east-1 (ou a que preferir)
# Formato de saída: json

Verifique se está tudo certo

aws sts get-caller-identity

PASSO 1: SUBIR A INFRAESTRUTURA

terraform init
terraform plan
terraform apply -auto-approve

Guarde as informações importantes

terraform output

PASSO 2: BUILD E PUSH DA IMAGEM DOCKER

cd modules/backend

# Pegue a URL do repositório (salve em uma variável)
export ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null)

# Se não funcionar, busque manualmente:
# 1. Acesse console AWS > ECR
# 2. Copie a URI do repositório

# Login (extraia apenas o domínio: account.dkr.ecr.region.amazonaws.com)
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $(echo $ECR_URL | cut -d/ -f1)

  # Build da imagem
docker build -t dreamsquad-challenge-repo .

# Tag com a URL do ECR
docker tag dreamsquad-challenge-repo:latest $ECR_URL:latest

# Push para o ECR
docker push $ECR_URL:latest

# Volte para a raiz do projeto
cd ../..

PASSO 3: FORÇAR O DEPLOY NO ECS
Atualizar o serviço para usar a nova imagem
bash
aws ecs update-service \
  --cluster dreamsquad-challenge-cluster \
  --service dreamsquad-challenge-service \
  --force-new-deployment \
  --region us-east-1
Aguardar o serviço ficar estável

aws ecs wait services-stable \
  --cluster dreamsquad-challenge-cluster \
  --service dreamsquad-challenge-service \
  --region us-east-1

  PASSO 4: VERIFICAR SE TUDO FUNCIONA
1. Testar o frontend
   
# Pegar a URL
terraform output frontend_url

# Abrir no navegador
echo "https://$(terraform output -raw frontend_url)"
