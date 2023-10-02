
output "rds_endpoint" {
  description = "Rds Endpoint"
  value = aws_rds_cluster.aurora_postgresql.endpoint
}
output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.my_ec2_instance.id
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.api_log_group.name
}

output "repo_url" {
  description = "ECR Repository Url"
  value = aws_ecr_repository.ecr_repo.repository_url
}
