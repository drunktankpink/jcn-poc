output "cluster_arn" {
  description = "Cluster ARNr"
  value       = aws_ecs_cluster.this.cluster_arn
}

output "cluster_id" {
  description = "Cluster ID"
  value       = aws_ecs_cluster.this.cluster_id
}

output "cluster_name" {
  description = "Cluter name"
  value       = aws_ecs_cluster.this.cluster_name
}
