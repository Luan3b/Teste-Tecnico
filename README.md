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
