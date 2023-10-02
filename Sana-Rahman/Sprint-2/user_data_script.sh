#!/bin/bash
echo "Executing Commands!"

sudo yum update -y         # Optional: Update the package index
sudo yum install docker -y # Install Docker (for Amazon Linux 2)
sudo service docker start  # Start Docker service

DB_CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id ${var.database_secret_name})

# Retrieve ECR authentication token and pull the Docker images
aws ecr get-login-password --region ${region} | sudo docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${region}.amazonaws.com
sudo docker network create api_caller_network

sudo docker pull ${aws_ecr_repository.ecr_repo.repository_url}:frontimg
sudo docker run -d --name frontend_container -p 3000:3000 --network api_caller_network ${aws_account_id}.dkr.ecr.ap-southeast-1.amazonaws.com/my_ecr_repo:frontimg

sudo docker pull ${aws_ecr_repository.ecr_repo.repository_url}:back_api
sudo docker run -d --name backend_container -e DB_HOST="${rds_endpoint}" -e DB_NAME="${database_name}" -e DB_USER="$(echo $DB_CREDENTIALS | jq -r '.SecretString | fromjson.username')" -e DB_PASSWORD="$(echo $DB_CREDENTIALS | jq -r '.SecretString | fromjson.password')" -p 5000:5001 --network api_caller_network ${aws_account_id}.dkr.ecr.ap-southeast-1.amazonaws.com/my_ecr_repo:back_api
