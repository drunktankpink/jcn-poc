resource "aws_ecs_cluster" "this" {
  name = "${var.service_name}-ecs-cluster"
}
