variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)

  default = {
    Name    = "Default_Name"
    Creator = "Sana Rahman"
    Project = "Sprint 3"
  }
}

variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  default     = "user-pool"
}

variable "cognito_client_name" {
  description = "Name of the Cognito User Pool Client"
  type        = string
  default     = "cognito-client"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for Public Subnet A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for Private Subnet A"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for Public Subnet B"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for Private Subnet B"
  type        = string
  default     = "10.0.4.0/24"
}

variable "availability_zone_a" {
  description = "Availability Zone for Public Subnet A"
  type        = string
  default     = "ap-southeast-1a"
}

variable "availability_zone_b" {
  description = "Availability Zone for Public Subnet B"
  type        = string
  default     = "ap-southeast-1b"
}

variable "all_cidr" {
  description = "Cidr Block allowing all Ip's"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port"
  type        = number
  default     = 443
}

variable "custom_port_1" {
  description = "Custom port 1"
  type        = number
  default     = 3000
}

variable "custom_port_2" {
  description = "Custom port 2"
  type        = number
  default     = 5000
}

variable "all_ports" {
  description = "Allows all ports"
  type        = number
  default     = 0
}

variable "protocol_tcp" {
  description = "TCP protocol"
  type        = string
  default     = "tcp"
}

variable "Postgres_port" {
  description = "Allows postgres port"
  type        = string
  default     = 5432
}

variable "protocol_http" {
  description = "HTTP protocol"
  type        = string
  default     = "http"
}

variable "domain_name" {
  description = "The root domain name"
  type        = string
  default     = "bootcamp1.xgrid.co"
}

variable "subdomain_name" {
  description = "The subdomain name"
  type        = string
  default     = "sana.bootcamp1.xgrid.co"
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "restapi"
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  default     = "postgres"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
  default     = "rds-instance"
}

variable "ecs_cpu" {
  description = "CPU value for ECS task"
  type        = string
  default     = "1024"
}

variable "ecs_memory" {
  description = "Memory value for ECS task"
  type        = string
  default     = "2048"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "my-ecs-cluster"
}

variable "ecs_network_mode" {
  description = "Network mode for ECS task"
  type        = string
  default     = "awsvpc"
}

variable "frontend_container_name" {
  description = "Name of the frontend container"
  type        = string
  default     = "frontend_container"
}

variable "backend_container_name" {
  description = "Name of the backend container"
  type        = string
  default     = "backend_container"
}

variable "alb_name" {
  description = "Name of the Application Load Balanacer"
  type        = string
  default     = "api-alb"
}

variable "load_balancer_type" {
  description = "Load Balancer Type  "
  type        = string
  default     = "application"
}

variable "enable_deletion_protection" {
  description = "Opption for enabling deletion protection"
  type        = string
  default     = "false"
}

variable "front_tg_name" {
  description = "Name for the frontend target group"
  type        = string
  default     = "frontend-tg"
}

variable "backend_tg_name" {
  description = "Name for the backend target group"
  type        = string
  default     = "backend-tg"
}

variable "ecr_iam_policy_name" {
  description = "Name for the AWS IAM policy for ECR"
  type        = string
  default     = "ecr_policy"
}

variable "ecs_iam_role_name" {
  description = "Name for the AWS IAM role for ECS"
  type        = string
  default     = "ecs_execution_role"
}

variable "ecr_repository_name" {
  description = "Name of the existing AWS ECR repository"
  type        = string
  default     = "my_ecr_repo"
}

variable "ecs_service_name" {
  description = "Name for the AWS ECS service"
  type        = string
  default     = "api-service"
}

variable "db_subnet_group_name" {
  description = "Name for the AWS RDS subnet group"
  type        = string
  default     = "rds-subnet"
}

variable "sg_name_ecs" {
  description = "Prefix for the AWS security group name for Ecs"
  type        = string
  default     = "ecs-sg"
}

variable "sg_name_rds" {
  description = "Prefix for the AWS security group name for Rds"
  type        = string
  default     = "rds-sg"
}

variable "sg_name_alb" {
  description = "Prefix for the AWS security group name for Alb"
  type        = string
  default     = "alb-sg"
}

variable "alb_internal" {
  description = "Sets Alb to internal"
  type        = string
  default     = "false"
}

variable "ecs_task_family" {
  description = "Family name for the AWS ECS task definition"
  type        = string
  default     = "api-task"
}
