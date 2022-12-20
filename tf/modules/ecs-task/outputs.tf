output "service_id" {
  description = "ECS service ID"
  value       = aws_ecs_service.this.id
}
