variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "service_name" {
  description = "The ECS service name"
  type        = string
}

variable "container_image" {
  description = "The container image"
  type        = string
  default     = "hello-world"
}

variable "memory" {
  description = "Memory allocation"
  type        = number
  default     = 128
}

variable "desired_count" {
  description = "The desired count for ECS task"
  type        = number
  default     = 1
}
