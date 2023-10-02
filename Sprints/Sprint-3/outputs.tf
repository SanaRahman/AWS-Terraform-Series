output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.custom_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the Public Subnets"
  value       = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

output "private_subnet_ids" {
  description = "IDs of the Private Subnets"
  value       = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

output "nat_gateway_ip" {
  description = "Elastic IP address of the NAT Gateway"
  value       = aws_eip.eip_a.id
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.my_alb.name
}

output "frontend_task_definition" {
  description = "ARN of the frontend ECS task definition"
  value       = aws_ecs_task_definition.api_task.arn
}

output "backend_task_definition" {
  description = "ARN of the backend ECS task definition"
  value       = aws_ecs_task_definition.api_task.arn
}

output "rds_instance_endpoint" {
  description = "Endpoint address of the RDS instance"
  value       = aws_db_instance.rds_instance.endpoint
}

output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.rds_instance.id
}

output "user_pool_id" {
  description = "ID of the AWS Cognito User Pool"
  value       = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  description = "ID of the AWS Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.client.id
}
