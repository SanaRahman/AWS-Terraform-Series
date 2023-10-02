#__________________MY VPC CREATION______________________
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
 
  tags = merge(var.tags, {
    Name = "My_VPC"
  })
}
#___________MY SUBNETS AND SUBNET GROUPS__________
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = var.public_subnet_ava_zone
  
   tags = merge(var.tags, {
    Name    = "Public_subnet"
  })
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet1_cidr_block
  availability_zone = var.private_subnet1_ava_zone
   tags = merge(var.tags, {
   Name    = "Private_Subnet"
  })
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet2_cidr_block
  availability_zone = var.private_subnet2_ava_zone
  tags = merge(var.tags, {
   Name    = "Private_Subnet2"
  })
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet_group"
  subnet_ids = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet.id]

  tags = {
    Name    = "My_DB_subnet_group"
    Creator = "Sana Rahman"
    Project = "Sprint 2"
  }
}

#__________________GATEWAY CREATION____________________

#making an internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = merge(var.tags, {
   Name    = "Internet_gateway"
  }) 
}

#elastic ip
resource "aws_eip" "eip" {
  vpc = true
   tags = merge(var.tags, {
   Name    = "Elastic_ip"
  })
}
#nat gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = merge(var.tags, {
   Name    = "Nat_Gateway"
  })
  depends_on = [aws_internet_gateway.internet_gateway]
}

#_______________ROUTE TABLES AND ASSOCIATIONS______________
#Routing table description
resource "aws_route_table" "my_public_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = merge(var.tags, {
   Name    = "Public_Route_table"
  })

}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.my_public_route.id
}

resource "aws_route_table" "my_private_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = merge(var.tags, {
   Name    = "Private_Route_Table"
  })
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.my_private_route.id
}

#______________SECURITY GROUPS______________
# Security Group for Ec2 Instance
resource "aws_security_group" "ec2_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  # Allow inbound SSH traffic from a specific IP
  ingress {
    description = "Ingress rule for ssh"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks 
  }
  ingress {
    description = "Ingress rule for frontend"
    from_port   = var.frontend_port
    to_port     = var.frontend_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks
  }
  ingress {
    description = "Ingress rule for backend"
    from_port   = var.backend_port
    to_port     = var.backend_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks 
  }
  egress {
    from_port   = var.egress_port
    to_port     = var.egress_port
    protocol    = "-1"
    cidr_blocks = var.egress_cidr_blocks
  }
   tags = merge(var.tags, {
    Name    = "Public_Security_Group"
  })

}

# Security Group for RDS Instance
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds_instance_sg"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port = var.rds_port
    to_port   = var.rds_port
    protocol  = var.egress_protocol
    security_groups = [aws_security_group.ec2_sg.id]
  }
    tags = merge(var.tags, {
    Name    = "Private_Security_Group"
  })

}

#_____________SERVERLESS DB SETUP_____________

# Amazon Aurora Serverless Cluster for PostgreSQL
resource "aws_rds_cluster" "aurora_postgresql" {
  cluster_identifier     = "aurora-postgresql"
  engine                 = "aurora-postgresql"
  engine_mode            = "provisioned"
  engine_version         = var.arora_engine_v
  database_name          = var.database_name
  master_username        = var.master_username
  master_password        = var.master_password
  skip_final_snapshot    = true
  availability_zones     = [var.private_subnet2_ava_zone]
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
  tags = merge(var.tags, {
        Name    = "Aurora_Serverless_Cluster"
  })

}

# Amazon Aurora Serverless Cluster Instance for PostgreSQL
resource "aws_rds_cluster_instance" "aurora_postgresql_instance" {
  cluster_identifier = aws_rds_cluster.aurora_postgresql.id
  instance_class     = var.rds_cluster_instance_class
  engine             = aws_rds_cluster.aurora_postgresql.engine
  engine_version     = aws_rds_cluster.aurora_postgresql.engine_version
}

data "aws_rds_cluster" "rds_endpoint" {
  cluster_identifier = aws_rds_cluster.aurora_postgresql.cluster_identifier
}

output "rds_cluster_endpoint" {
  value = data.aws_rds_cluster.rds_endpoint.endpoint
}

#_____________EC2 and ECR SETUP _____________
data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
resource "aws_instance" "my_ec2_instance" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true 
  depends_on                  = [aws_rds_cluster_instance.aurora_postgresql_instance]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
   
  
   user_data = templatefile(var.user_data_path, {
    region          = var.region,
    aws_account_id  = var.aws_account_id,
    rds_endpoint    = data.aws_rds_cluster.rds_endpoint.endpoint,
    database_name   = var.database_name,
    master_username        = aws_secretsmanager_secret_version.database_secret_version.secret_string["username"]
    master_password        = aws_secretsmanager_secret_version.database_secret_version.secret_string["password"]
  })
  tags = merge(var.tags, {
   Name    = "MY_ec2_Instance"
  })
}

# Create IAM policy
resource "aws_iam_policy" "ecr_policy" {
  name   = "ecr_policy"
  policy = file("./ecr_policy.json")
   tags = merge(var.tags, {
      Name = "ecr_policy"
  })
}

# Create IAM role
resource "aws_iam_role" "ecr_role" {
  name = "ecr_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = merge(var.tags, {
    Name = "ecr_role"
  })
  
}
# Attach IAM policy to IAM role
resource "aws_iam_role_policy_attachment" "ecr_role_attachment" {
  policy_arn = aws_iam_policy.ecr_policy.arn
  role       = aws_iam_role.ecr_role.name
}
# Create the IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "MyEC2InstanceProfile"
  role = aws_iam_role.ecr_role.name
    tags = merge(var.tags, {
       Name = "ecr_profile"
  })
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "my-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 23
        height = 10

        properties = {
          view    = "timeSeries",
          stacked = false,
          metrics = [["AWS/EC2", "4xxErrorCount", "InstanceId", aws_instance.my_ec2_instance.id],
          ["AWS/EC2", "NetworkPacketsIn", "InstanceId", aws_instance.my_ec2_instance.id]],

          period = 300,
          stat   = "Average",
          region = var.region
          title  = "EC2 Error Logs"
        }
      },
    ]
  })

}

resource "aws_cloudwatch_log_group" "api_log_group" {
  name              = "logs"
  retention_in_days = 7

}

resource "aws_cloudwatch_metric_alarm" "backend_4xx_alarm" {
  alarm_name          = "HttpErrorAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "4xxErrorCount"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "HTTP 4xx Errors Alarm"
  alarm_actions       = [aws_sns_topic.sms_topic.arn]
  dimensions = {
    InstanceId = aws_instance.my_ec2_instance.id
  }
}

resource "aws_sns_topic" "sms_topic" {
  name = "alert-topic"
}

resource "aws_sns_topic_subscription" "sms_subscription" {
  topic_arn = aws_sns_topic.sms_topic.arn
  protocol  = "email"
  endpoint  =  var.email
}

resource "aws_secretsmanager_secret" "database_secret" {
  name = var.database_secret_name
}

resource "aws_secretsmanager_secret_version" "database_secret_version" {
  secret_id     = aws_secretsmanager_secret.database_secret.id
  secret_string = jsonencode({
    username = var.database_username,
    password = var.database_password,
  })
}
resource "aws_ecr_repository" "ecr_repo" {
  name = var.ecr_repo_name
}
