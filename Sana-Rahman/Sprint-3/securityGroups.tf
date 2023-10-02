# Define security group for ECS instances
resource "aws_security_group" "ecs_sg" {
  name_prefix = var.sg_name_ecs
  vpc_id      = aws_vpc.custom_vpc.id

  # Allow incoming SSH, HTTP, HTTPS, and custom ports
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.protocol_tcp
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = var.protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.custom_port_1
    to_port     = var.custom_port_1
    protocol    = var.protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.custom_port_2
    to_port     = var.custom_port_2
    protocol    = var.protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = var.all_ports
    to_port     = var.all_ports
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "MyECSSecurityGroup"
  })
}

# Define security group for Application Load Balancer (ALB)
resource "aws_security_group" "alb_sg" {
  name_prefix = var.sg_name_alb
  vpc_id      = aws_vpc.custom_vpc.id

  # Allow incoming HTTP, HTTPS, SSH, and custom ports
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.custom_port_2
    to_port     = var.custom_port_2
    protocol    = var.protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = var.protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.custom_port_1
    to_port     = var.custom_port_1
    protocol    = var.protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH outbound traffic (replace with your public IP)
  egress {
    description = "Ingress rule for SSH"
    from_port   = var.all_ports
    to_port     = var.all_ports
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "MyALBSecurityGroup"
  })
}

# Define security group for RDS instances
resource "aws_security_group" "rds_sg" {
  name_prefix = var.sg_name_rds
  vpc_id      = aws_vpc.custom_vpc.id

  # Allow incoming PostgreSQL traffic from EC2 instances
  ingress {
    description     = "Allow EC2 instances"
    from_port       = var.Postgres_port
    to_port         = var.Postgres_port
    protocol        = var.protocol_tcp
    security_groups = [aws_security_group.ecs_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = var.all_ports
    to_port     = var.all_ports
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "MyRDSSecurityGroup"
  })
}
