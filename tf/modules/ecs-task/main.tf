resource "aws_cloudwatch_log_group" "this" {
  name_prefix       = "${var.service_name}-"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "this" {
  family = "${var.service_name}"

  container_definitions = <<EOF
[
  {
    "name": "${var.service_name}",
    "image": "${var.container_image}",
    "cpu": 0,
    "memory": ${var.memory},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "eu-west-2",
        "awslogs-group": "${aws_cloudwatch_log_group.this.name}",
        "awslogs-stream-prefix": "ec2"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "this" {
  name            = "${var.service_name}"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn

  desired_count   = var.desired_count

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}
