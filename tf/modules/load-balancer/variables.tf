variable "service_name" {
  description = "The ECS service name"
  type        = string
}

variable "internal" {
  description = "Load balancer internal"
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "Load balance type"
  type        = string
  default     = "application"
}

variable "lb_protocol" {
  description = "Load balance protocol"
  type        = string
  default     = "HTTP"
}

variable "subnets" {
  description = "Subnets to use"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "security_groups" {
  description = "security group for alb"
  type        = list(string)
}


# target group
variable "lb_port" {
  description = "The LB target type"
  type        = string
  default     = ""
}

variable "target_type" {
  description = "The LB target type"
  type        = string
  default     = ""
}

variable "ecs_target_id" {
  description = "ECS target Id"
  type        = string
}
