DreamSquad DevOps Challenge

Este projeto implementa uma infraestrutura completa na AWS utilizando Infrastructure as Code (IaC) com Terraform.

A solução provisiona automaticamente uma aplicação serverless composta por:

Backend API em Flask rodando no ECS Fargate

Frontend estático hospedado no S3 e distribuído pelo CloudFront

Lambda agendada para geração automática de arquivos

Infraestrutura de rede completa (VPC, subnets, ALB, etc.)

🏗️ Arquitetura da Solução

A aplicação segue uma arquitetura baseada em serviços gerenciados da AWS.

Componentes principais:

Amazon ECS Fargate → Executa a API Flask em container

Amazon ECR → Armazena a imagem Docker da aplicação

Application Load Balancer (ALB) → Distribui o tráfego para os containers

Amazon S3 → Hospeda o site estático

Amazon CloudFront → CDN global para entrega do frontend

AWS Lambda → Geração automática de arquivos

Amazon EventBridge → Agendamento da execução da Lambda

Amazon VPC → Isolamento da infraestrutura de rede

📂 Estrutura do Projeto
dreamsquad-challenge/

 ├── main.tf            # Orquestração dos módulos
 
 ├── provider.tf        # Configuração do AWS Provider
 
 ├── variables.tf       # Variáveis globais
 
 ├── versions.tf        # Versões dos providers
 
 ├── outputs.tf         # Outputs globais
 


├── modules/

│   ├── backend/       # Módulo da API Flask

│   │   ├── main.tf

│   │   ├── outputs.tf

│   │   ├── variables.tf

│   │   ├── app.py

│   │   └── requirements.txt

│   │
│   ├── frontend/      # Módulo do site estático

│   │   ├── main.tf

│   │   ├── outputs.tf

│   │   ├── variables.tf

│   │   ├── index.html.tpl

│   │   └── style.css

│   │
│   └── lambda_daily/  # Módulo da Lambda agendada

│       ├── main.tf

│       ├── outputs.tf

│       ├── variables.tf

│       └── lambda/

│           └── handler.py
⚙️ Pré-requisitos

Antes de iniciar, instale:

Terraform

Docker

AWS CLI

Configure suas credenciais AWS:

aws configure

Informe:

AWS Access Key ID
AWS Secret Access Key
Region: us-east-1
Output format: json

Teste se a configuração está correta:

aws sts get-caller-identity
🚀 Deploy da Infraestrutura

Inicialize o Terraform:

terraform init

Visualize o plano de execução:

terraform plan

Aplicar a infraestrutura:

terraform apply -auto-approve

Verificar os outputs:

terraform output
🐳 Build e Push da Imagem Docker

Entre no diretório do backend:

cd modules/backend

Obtenha a URL do repositório ECR:

export ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null)

Login no ECR:

aws ecr get-login-password --region us-east-1 \
| docker login --username AWS --password-stdin $(echo $ECR_URL | cut -d/ -f1)

Build da imagem:

docker build -t dreamsquad-challenge-repo .

Tag da imagem:

docker tag dreamsquad-challenge-repo:latest $ECR_URL:latest

Push da imagem:

docker push $ECR_URL:latest

Voltar para a raiz do projeto:

cd ../..
🔄 Atualizar Deploy no ECS

Forçar novo deploy do serviço:

aws ecs update-service \
--cluster dreamsquad-challenge-cluster \
--service dreamsquad-challenge-service \
--force-new-deployment \
--region us-east-1

Aguardar o serviço estabilizar:

aws ecs wait services-stable \
--cluster dreamsquad-challenge-cluster \
--service dreamsquad-challenge-service \
--region us-east-1
🌐 Testando a Aplicação

Obter a URL do frontend:

terraform output frontend_url

Abrir no navegador:

https://$(terraform output -raw frontend_url)
🧠 Funcionalidades

✔ Infraestrutura automatizada com Terraform
✔ Backend containerizado com Docker
✔ Deploy serverless com ECS Fargate
✔ CDN global com CloudFront
✔ Geração automática de arquivos com Lambda
✔ Arquitetura modular com Terraform
