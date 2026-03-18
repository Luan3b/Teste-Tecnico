# 🚀 DreamSquad Challenge

Infraestrutura como Código (IaC) para uma aplicação serverless na AWS.

## 📋 Stack
- **Terraform** - Infraestrutura como código
- **AWS ECS Fargate** - Backend Flask
- **S3 + CloudFront** - Frontend estático
- **Lambda + EventBridge** - Geração diária de arquivos
- **GitHub Actions** - CI/CD automatizado

## 🚀 Deploy Rápido

```bash
# 1. Configurar credenciais AWS
aws configure

# 2. Deploy da infraestrutura
terraform init
terraform apply -auto-approve

# 3. Build e push da imagem
docker build -t dreamsquad-backend .
docker tag dreamsquad-backend:latest $(terraform output -raw ecr_repository_url):latest
docker push $(terraform output -raw ecr_repository_url):latest

# 4. Deploy da aplicação
aws ecs update-service \
  --cluster $(terraform output -raw cluster_name) \
  --service $(terraform output -raw service_name) \
  --force-new-deployment \
  --region us-east-1

  🌐 Endpoints
Frontend: https://$(terraform output -raw frontend_url)

Backend API: $(terraform output -raw backend_api_url)

📦 Estrutura
text
.
├── app/               # Código da aplicação
├── modules/           # Módulos Terraform
├── tests/             # Testes automatizados
└── scripts/           # Scripts utilitários

🧪 Testes
bash
pip install pytest moto
pytest tests/ -v

🧹 Limpeza
bash
terraform destroy -auto-approve

Desenvolvido por Luan Borba ☁️