resource "aws_vpc" "tictactoe_vpc" {
  cidr_block            = "10.0.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name = "tictactoe-vpc"
  }
}

resource "aws_subnet" "tictactoe_subnet1" {
  vpc_id                = aws_vpc.tictactoe_vpc.id
  cidr_block            = "10.0.1.0/24"
  availability_zone     = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "tictactoe-public-subnet-1"
  }
}

resource "aws_subnet" "tictactoe_subnet2" {
  vpc_id                = aws_vpc.tictactoe_vpc.id
  cidr_block            = "10.0.2.0/24"
  availability_zone     = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "tictactoe-public-subnet-2"
  }
}

resource "aws_internet_gateway" "tictactoe_gateway" {
  vpc_id = aws_vpc.tictactoe_vpc.id
  tags = {
    Name = "tictactoe-IGW"
  }
}

resource "aws_route_table" "tictactoe_route_table" {
  vpc_id = aws_vpc.tictactoe_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tictactoe_gateway.id
  }
  tags = {
    Name = "tictactoe-routetable"
  }
}

resource "aws_route_table_association" "tictactoe_route_association1" {
  subnet_id      = aws_subnet.tictactoe_subnet1.id
  route_table_id = aws_route_table.tictactoe_route_table.id
}

resource "aws_route_table_association" "tictactoe_route_association2" {
  subnet_id      = aws_subnet.tictactoe_subnet2.id
  route_table_id = aws_route_table.tictactoe_route_table.id
}

resource "aws_security_group" "backend_sg" {
  name        = "backend_sg"
  description = "Allow backend traffic"
  vpc_id      = aws_vpc.tictactoe_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend_sg"
  }
}

resource "aws_security_group" "frontend_sg" {
  name        = "frontend_sg"
  description = "Allow frontend traffic"
  vpc_id      = aws_vpc.tictactoe_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend_sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow load balancer traffic"
  vpc_id      = aws_vpc.tictactoe_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend_sg"
  }
}

resource "aws_alb" "main" {
  name            = "tictactoe-alb"
  subnets         = [aws_subnet.tictactoe_subnet1.id, aws_subnet.tictactoe_subnet2.id]
  security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_alb_target_group" "alb_target_gr_back" {
  name        = "alb-target-gr-back"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.tictactoe_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 3
    interval            = 30
    protocol            = "HTTP"
    matcher             = 200
    timeout             = 3
    path                = "/"
    unhealthy_threshold = 2
  }
}

resource "aws_alb_target_group" "alb_target_gr_front" {
  name        = "alb-target-gr-front"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.tictactoe_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 3
    interval            = 30
    protocol            = "HTTP"
    matcher             = 200
    timeout             = 3
    path                = "/"
    unhealthy_threshold = 2
  }
}

resource "aws_alb_listener" "alb_listener_backend" {
  load_balancer_arn = aws_alb.main.id
  port              = 8080
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_gr_back.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "alb_listener_frontend" {
  load_balancer_arn = aws_alb.main.id
  port              = 3000
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_gr_front.id
    type             = "forward"
  }
}

resource "aws_ecs_cluster" "tictactoe_cluster" {
  name = "TictactoeCluster"
}

resource "aws_ecs_task_definition" "tictactoe_backend_task" {
  family                   = "TictactoeBackend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::851725643716:role/LabRole"
  task_role_arn            = "arn:aws:iam::851725643716:role/LabRole"

  container_definitions = jsonencode([
    {
      name        = "backend"
      image       = "851725643716.dkr.ecr.us-east-1.amazonaws.com/tictactoe_back:a12"
      essential   = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ALB_DNS_NAME"
          value = "${aws_alb.main.dns_name}"
        },
        {
          name  = "COGNITO_USER_POOL_ID"
          value = aws_cognito_user_pool.test_pool.id
        },
        {
          name  = "COGNITO_CLIENT_ID"
          value = aws_cognito_user_pool_client.public_client.id
        },
        {
          name  = "S3_BUCKET_NAME"
          value = aws_s3_bucket.profile_pictures.bucket
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "tictactoe_frontend_task" {
  family                   = "TictactoeFrontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::851725643716:role/LabRole"
  task_role_arn            = "arn:aws:iam::851725643716:role/LabRole"

  container_definitions = jsonencode([
    {
      name        = "frontend"
      image       = "851725643716.dkr.ecr.us-east-1.amazonaws.com/tictactoe_front:a12"
      essential   = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ALB_DNS_NAME"
          value = "${aws_alb.main.dns_name}"
        },
        {
          name  = "COGNITO_USER_POOL_ID"
          value = aws_cognito_user_pool.test_pool.id
        },
        {
          name  = "COGNITO_CLIENT_ID"
          value = aws_cognito_user_pool_client.public_client.id
        }
      ]
    }
  ])

  depends_on = [aws_s3_bucket.profile_pictures, aws_cognito_user_pool.test_pool, aws_cognito_user_pool_client.public_client]
}

resource "aws_ecs_service" "tictactoe_backend_service" {
  name            = "TictactoeBackendService"
  cluster         = aws_ecs_cluster.tictactoe_cluster.id
  task_definition = aws_ecs_task_definition.tictactoe_backend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  
  network_configuration {
    subnets          = [aws_subnet.tictactoe_subnet1.id, aws_subnet.tictactoe_subnet2.id]
    security_groups  = [aws_security_group.backend_sg.id]
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = aws_alb_target_group.alb_target_gr_back.id
    container_name   = "backend"
    container_port   = 8080
  }

  depends_on = [aws_ecs_task_definition.tictactoe_backend_task, aws_alb_listener.alb_listener_backend]
}

resource "aws_ecs_service" "tictactoe_frontend_service" {
  name            = "TictactoeFrontendService"
  cluster         = aws_ecs_cluster.tictactoe_cluster.id
  task_definition = aws_ecs_task_definition.tictactoe_frontend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  
  network_configuration {
    subnets          = [aws_subnet.tictactoe_subnet1.id, aws_subnet.tictactoe_subnet2.id]
    security_groups  = [aws_security_group.frontend_sg.id]
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = aws_alb_target_group.alb_target_gr_front.id
    container_name   = "frontend"
    container_port   = 3000
  }

  depends_on = [aws_ecs_task_definition.tictactoe_frontend_task, aws_alb_listener.alb_listener_frontend]
}

output "alb_backend" {
  value = "http://${aws_alb.main.dns_name}:8080"
}

output "alb_frontend" {
  value = "http://${aws_alb.main.dns_name}:3000"
}
