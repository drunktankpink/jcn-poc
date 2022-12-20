resource "aws_ecs_task_definition" "this" {
  family = "${var.service_name}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.task_exe_role
  #task_role_arn            = var.task_def_role

  container_definitions = jsonencode([{
    name        = "${var.service_name}-container"
    image       = "${var.container_image}"
    essential   = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
  }])
}

resource "aws_ecs_service" "this" {
  name                                = var.service_name
  cluster                             = var.cluster_id
  task_definition                     = aws_ecs_task_definition.this.arn
  desired_count                       = var.desired_count
  deployment_maximum_percent          = 100
  deployment_minimum_healthy_percent  = 0
  launch_type                         = "FARGATE"
  scheduling_strategy                 = "REPLICA"

  network_configuration {
    security_groups   = var.security_groups
    subnets           = var.subnets
    assign_public_ip  = false
  }

  load_balancer {
    target_group_arn  = var.target_group_arn
    container_name    = "${var.service_name}-container"
    container_port    = var.container_port
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_security_group" "this" {
  name   = "${var.service_name}-task-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.container_port
    to_port          = var.container_port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
