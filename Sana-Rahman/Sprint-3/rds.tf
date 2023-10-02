# Create RDS subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  tags = merge(var.tags, {
    Name = "MyRDSSubnetGroup"
  })
}

# Create RDS instance
resource "aws_db_instance" "rds_instance" {
  identifier             = var.rds_identifier
  engine                 = "postgres"
  instance_class         = var.rds_instance_class
  allocated_storage      = 10
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible    = false
  storage_type           = "gp2"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = merge(var.tags, {
    Name = "MyRDSInstance"
  })
}

# Calculate RDS endpoint
locals {
  rdsendpoint  = aws_db_instance.rds_instance.endpoint
  rds_endpoint = substr(local.rdsendpoint, 0, length(local.rdsendpoint) - 5)
}
