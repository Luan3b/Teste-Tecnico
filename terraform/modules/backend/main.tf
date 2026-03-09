# Obtém automaticamente as zonas de disponibilidade disponíveis na região
data "aws_availability_zones" "available" {}

# Criação da VPC onde toda a infraestrutura do backend será criada
resource "aws_vpc" "backend_vpc" {

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Criação de duas subnets públicas distribuídas em diferentes AZs
resource "aws_subnet" "public" {

  count = 2

  vpc_id = aws_vpc.backend_vpc.id

  cidr_block = "10.0.${count.index}.0/24"

  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true
}

# Internet Gateway para permitir acesso à internet na VPC
resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.backend_vpc.id
}

# Tabela de rotas pública para permitir saída para internet
resource "aws_route_table" "public" {

  vpc_id = aws_vpc.backend_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associação da tabela de rotas com as subnets públicas
resource "aws_route_table_association" "public" {

  count = 2

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public.id
}

# Security Group do Application Load Balancer
resource "aws_security_group" "alb_sg" {

  name = "${var.project_name}-alb-sg"

  vpc_id = aws_vpc.backend_vpc.id

# Permite tráfego HTTP da internet
  ingress {

    from_port = 80
    to_port = 80# Template utilizado para gerar dinamicamente o index.html
    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

# Permite saída para qualquer destino
  egress {

    from_port = 0
    to_port = 0
    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group das tarefas ECS
resource "aws_security_group" "ecs_sg" {

  name = "${var.project_name}-ecs-sg"

  vpc_id = aws_vpc.backend_vpc.id
# Permite tráfego apenas vindo do ALB
  ingress {

    from_port = 5000
    to_port = 5000
    protocol = "tcp"

    security_groups = [aws_security_group.alb_sg.id]
  }

# Permite saída para qualquer destino
  egress {

    from_port = 0
    to_port = 0
    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Repositório ECR onde a imagem Docker do backend será armazenada
resource "aws_ecr_repository" "backend" {

  name = "${var.project_name}-repo"
}

# Cluster ECS onde os containers serão executados
resource "aws_ecs_cluster" "backend_cluster" {

  name = "${var.project_name}-cluster"
}

# Application Load Balancer para distribuir tráfego para os containers
resource "aws_lb" "backend_alb" {

  name = "${var.project_name}-alb"

  load_balancer_type = "application"

  subnets = aws_subnet.public[*].id

  security_groups = [aws_security_group.alb_sg.id]
}

# Target Group do ALB que aponta para os containers ECS
resource "aws_lb_target_group" "backend_tg" {
  name        = "${var.project_name}-tg"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.backend_vpc.id

 # Health check para verificar se o container está funcionando
health_check {
    path                = "/" # Usa a rota de health que você criou
    port                = "5000"
    interval            = 30
    matcher             = "200" # Espera status 200 OK
  }
}

# Listener do ALB que recebe tráfego HTTP e encaminha para o Target Group
resource "aws_lb_listener" "backend_listener" {

  load_balancer_arn = aws_lb.backend_alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# Role utilizada pelas tarefas ECS para acessar serviços da AWS
resource "aws_iam_role" "ecs_task_execution" {

  name = "${var.project_name}-ecs-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "ecs-tasks.amazonaws.com"

        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Policy padrão da AWS para execução de tarefas ECS
resource "aws_iam_role_policy_attachment" "ecs_policy" {

  role = aws_iam_role.ecs_task_execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Definição da Task ECS que executará o container backend
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "${var.project_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  # Adicione esta linha abaixo para seu código Python ter permissão no S3
  task_role_arn      = aws_iam_role.ecs_task_execution.arn
  
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true

      # Adicione variáveis de ambiente para o seu código saber qual bucket ler
      environment = [
        { name = "BUCKET_NAME", value = "dreamsquad-challenge-dev-daily-files" }
      ]

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

# Serviço ECS que mantém o container em execução
resource "aws_ecs_service" "backend_service" {

  name = "${var.project_name}-service"

  cluster = aws_ecs_cluster.backend_cluster.id

  task_definition = aws_ecs_task_definition.backend_task.arn

  desired_count = 1

  launch_type = "FARGATE"

  network_configuration {

    subnets = aws_subnet.public[*].id

    security_groups = [aws_security_group.ecs_sg.id]

    assign_public_ip = true
  }

# Integração do serviço com o Load Balancer
  load_balancer {

    target_group_arn = aws_lb_target_group.backend_tg.arn

    container_name = "backend"

    container_port = 5000
  }

  depends_on = [
    aws_lb_listener.backend_listener
  ]
}

# Policy para o Backend acessar o S3
resource "aws_iam_role_policy" "ecs_s3_policy" {
  name = "${var.project_name}-s3-policy"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetObject"]
        # Use o nome exato que você colocou no environment da Task Definition
        Resource = [
          "arn:aws:s3:::dreamsquad-challenge-dev-daily-files",
          "arn:aws:s3:::dreamsquad-challenge-dev-daily-files/*"
        ]
      }
    ]
  })
}