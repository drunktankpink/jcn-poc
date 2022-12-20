# Data
data "aws_region" "current" { }

data "aws_availability_zones" "available" {
  state = "available"
}

# Locals
locals {
  location_abr       = replace(data.aws_region.current.name, "/^([a-z]{2})-(.)(.{0.})-([0-9])/", "$1$2$4")
  availability_zones = data.aws_availability_zones.available.names
  subnet_abr         = [for az in data.aws_availability_zones.available.names : replace(az, "/^([a-z]{2})-(.)(.{0.})-([0-9])/", "$1$2$4")]
  subnet_count       = length(data.aws_availability_zones.available.names)

}

# loadbalancer
resource "aws_lb" "this" {
  name               = "${var.service_name}-${local.location_abr}-lb"
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  subnets            = var.subnets
  security_groups    = var.load_balancer_type == "application" ? [var.security_groups] : null
  
  idle_timeout                     = var.idle_timeout
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  ip_address_type                  = var.ip_address_type
  
  tags = {
    Name = "${var.service_name}-${local.location_abr}-lb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.service_name}-${local.location_abr}-tg"
  port        = var.lb_port
  protocol    = local.lb_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

    health_check {
      protocol            = local.lb_protocol
      port                = var.lb_port
      interval            = 10
      matcher             = var.load_balancer_type == "application" ? "200" : null
      healthy_threshold   = 1
      unhealthy_threshold = 1
  }
  tags = {
    Name        = "${var.service_name}-${local.location_abr}-lb"
    Environment = var.resource_environment
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.lb_port
  protocol          = local.lb_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = var.instance_ids[count.index]
  port             = var.lb_port
}
