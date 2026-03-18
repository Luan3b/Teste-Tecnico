# Guia de Contribuição

## Como contribuir com o projeto

### 1. Setup do ambiente

\`\`\`bash
# Clone o repositório
git clone git@github.com:your-username/dreamsquad-challenge.git
cd dreamsquad-challenge

# Crie um ambiente virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate  # Windows

# Instale dependências
pip install -r app/backend/requirements.txt
pip install pytest moto

# Configure as variáveis de ambiente
cp .env.example .env
# Edite .env com suas credenciais
\`\`\`

### 2. Executando testes

\`\`\`bash
# Rodar todos os testes
make test

# Rodar testes específicos
pytest tests/test_lambda.py -v
pytest tests/test_backend.py -v
\`\`\`

### 3. Desenvolvimento local com Docker

\`\`\`bash
# Build da imagem
make docker-build

# Rodar container
make docker-run

# Testes em container
make docker-test
\`\`\`

### 4. Deploy local com LocalStack

\`\`\`bash
# Iniciar LocalStack
make localstack-up

# Executar Terraform apontando para LocalStack
cd terraform
terraform init
terraform plan
\`\`\`
