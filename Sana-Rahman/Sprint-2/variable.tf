
variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = "435495016122"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "15.0.0.0/16"
}

variable "region" {
  description = "AWS region where resources will be provisioned"
  type        = string
  default     = "ap-southeast-1"
}
variable "database_secret_name" {
  description = "Name of the secret in Secrets Manager"
  type        = string
}

variable "database_name" {
  description = "Database name for RDS cluster"
  type        = string

}

variable "master_username" {
  description = "Master username for RDS cluster"
  type        = string
}

variable "master_password" {
  description = "Master password for RDS cluster"
  type        = string

}

variable "rds_cluster_instance_class" {
  description = "The RDS instance class for the Aurora cluster"
  type        = string
  default     = "db.t2.small"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "15.0.1.0/24"
}

variable "private_subnet1_cidr_block" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "15.0.2.0/24"
}

variable "private_subnet2_cidr_block" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "15.0.3.0/24"
}

variable "public_subnet_ava_zone" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "ap-southeast-1a"
}

variable "private_subnet1_ava_zone" {
  description = "Availability zone for private subnet 1"
  type        = string
  default     = "ap-southeast-1b"
}

variable "private_subnet2_ava_zone" {
  description = "Availability zone for private subnet 2"
  type        = string
  default     = "ap-southeast-1c"
}

variable "ssh_port" {
  description = "SSH ingress from port"
  type        = number
  default     = 22
}

variable "backend_port" {
  description = "backend ports for ec2"
  type        = number
  default     = 5000
}

variable "frontend_port" {
  description = "frontend port for ec2"
  type        = number
  default     = 3000
}

variable "egress_port" {
  description = "TCP egress to port"
  type        = number
  default     = 0
}

variable "egress_protocol" {
  description = "TCP egress protocol"
  type        = string
  default     = "tcp"
}

variable "egress_cidr_blocks" {
  description = "TCP egress CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "rds_port" {
  description = "RDS ingress to port"
  type        = number
  default     = 5432
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "cidr_block" {
  description = "Public CIDR Block"
  type        = string
  default     = "0.0.0.0/0"
}
variable "email" {
  description = "User email address to send notification in case of an alert."
  type        = string
  default     = "sanarahmna930@gmail.com"
}

variable "arora_engine_v" {
  description = "Arora Engine Version"
  type        = string
  default     = "13.6"
}

variable "user_data_path" {
   description = "Path to user data file"
  type        = string
  default     = "user_data_script.sh"
}

variable "ecr_repo_name" {
  type        = string
  description = "ECr repo name"
}

variable "tags" {
  type = map(string)

  default = {
    Name    = "Default_Name"
    Creator = "Sana Rahman"
    Project = "Sprint 2"
  }
}
