resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name

  tags = merge(var.tags, {
    Name = "MyECSCluster"
  })
}

# Create ECR policy
resource "aws_iam_policy" "ecr_policy" {
  name   = var.ecr_iam_policy_name
  policy = file("ecr_policy.json")

  tags = merge(var.tags, {
    Name = "MyECRPolicy"
  })
}

# IAM role for ECS task execution
resource "aws_iam_role" "ecs_execution_role" {
  name = var.ecs_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "MyECSExecutionRole"
  })
}

# Attach ECR policy to IAM role
resource "aws_iam_role_policy_attachment" "ecs_role_attachment" {
  policy_arn = aws_iam_policy.ecr_policy.arn
  role       = aws_iam_role.ecs_execution_role.name
}

# ECS task definition for the API
resource "aws_ecs_task_definition" "api_task" {
  family = var.ecs_task_family

  network_mode             = var.ecs_network_mode
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = var.frontend_container_name,
      image = "${data.aws_ecr_repository.existing_repo.repository_url}:front_updated2",

      portMappings = [
        {
          containerPort = var.custom_port_1,
          hostPort      = var.custom_port_1,
          protocol      = var.protocol_tcp,
          appProtocol   = var.protocol_http
        },
      ],
      essential = true,
      environment = [
        {
          name  = "REACT_APP_POOL_ID",
          value = aws_cognito_user_pool.user_pool.id,
        },
        {
          name  = "REACT_APP_CLIENT_ID",
          value = aws_cognito_user_pool_client.client.id,
        },
      ],
    },
    {
      name  = var.backend_container_name,
      image = "${data.aws_ecr_repository.existing_repo.repository_url}:back_port3"
      portMappings = [
        {
          containerPort = var.custom_port_2,
          hostPort      = var.custom_port_2,
          protocol      = var.protocol_tcp,
          appProtocol   = var.protocol_http
        },
      ],
      essential = true,
      environment = [
        {
          name  = "DB_HOST",
          value = local.rds_endpoint,
        },
        {
          name  = "DB_NAME",
          value = var.db_name,
        },
        {
          name  = "DB_USER",
          value = var.db_username,
        },
        {
          name  = "DB_PASSWORD",
          value = var.db_password,
        },
      ],
    },
  ])

  tags = merge(var.tags, {
    Name = "MyECSTaskDefinition"
  })
}

# ECS service for the API
resource "aws_ecs_service" "api_service" {
  name          = var.ecs_service_name
  cluster       = aws_ecs_cluster.ecs_cluster.id
  desired_count = 2

  # Use the latest ACTIVE revision of the task definition
  task_definition      = aws_ecs_task_definition.api_task.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA" # Use "DAEMON" for daemon scheduling
  force_new_deployment = true

  network_configuration {
    assign_public_ip = false
    subnets          = [aws_subnet.private_subnet_a.id]
    security_groups = [
      aws_security_group.ecs_sg.id,
      aws_security_group.rds_sg.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = var.frontend_container_name
    container_port   = var.custom_port_1
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = var.backend_container_name
    container_port   = var.custom_port_2
  }

  tags = merge(var.tags, {
    Name = "MyAppAutoScalingPolicy"
  })
}

# App Auto Scaling target for ECS Fargate service
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.api_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = merge(var.tags, {
    Name = "MyAppAutoScalingTarget"
  })
}

# App Auto Scaling policy for ECS Fargate service
resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      scaling_adjustment          = 1
      metric_interval_lower_bound = 0
    }

    step_adjustment {
      scaling_adjustment          = -1
      metric_interval_upper_bound = 0
    }
  }
}

# CloudWatch alarm to monitor CPU utilization of the ECS Fargate service.
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_alarm" {
  alarm_name          = "ecs-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"
  alarm_description   = "Alarm triggered when CPU utilization is high"
  alarm_actions       = [aws_appautoscaling_policy.ecs_policy.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.api_service.name
  }
}
