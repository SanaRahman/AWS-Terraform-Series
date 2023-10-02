resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name

  tags = merge(var.tags, {
    Name = "MyECSCluster"
  })
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
      image = "${data.aws_ecr_repository.existing_repo.repository_url}:${var.image_tag}",

      portMappings = [
        {
          containerPort = var.custom_port_1,
          hostPort      = var.custom_port_1,
          protocol      = var.protocol_tcp,
          appProtocol   = var.protocol_http
        },
      ],
      essential = true,
    },
    {
      name  = var.backend_container_name,
      image = "${data.aws_ecr_repository.existing_repo.repository_url}:backend"
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
  desired_count = 1

  # Use the latest ACTIVE revision of the task definition
  task_definition      = aws_ecs_task_definition.api_task.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA" # Use "DAEMON" for daemon scheduling
  force_new_deployment = true

  deployment_controller {
    type = "CODE_DEPLOY"
  }

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

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.backend_tg.arn
  #   container_name   = var.backend_container_name
  #   container_port   = var.custom_port_2
  # }

  tags = merge(var.tags, {
    Name = "MyAppAutoScalingPolicy"
  })
}

resource "aws_codedeploy_app" "codedeploy_app" {
  name             = var.codedeploy_app_name
  compute_platform = var.codedeploy_compute_platform
}

resource "aws_codedeploy_deployment_group" "my_deployment_group" {
  app_name               = aws_codedeploy_app.codedeploy_app.name
  deployment_config_name = var.deployment_congif
  deployment_group_name  = var.deployment_group_name
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.deployment_sucess_timeout
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }

  deployment_style {
    deployment_type   = var.deployment_type
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
    service_name = aws_ecs_service.api_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.https_listener.arn]
      }

      target_group {
        name = aws_lb_target_group.frontend_tg.name
      }

      target_group {
        name = aws_lb_target_group.green_frontend_tg.name
      }
    }
  }

  tags = merge(var.tags, {
    Name = "DeploymentGroup"
  })
}

# App Auto Scaling target for ECS Fargate service
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 2
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

# Create an S3 bucket for pipeline artifacts
resource "aws_s3_bucket" "sana-pipeline-bucket" {
  bucket = var.s3_bucket
  acl    = "private"

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(var.tags, {
    Name = "S3Bucket"
  })
}

resource "aws_codebuild_project" "api_codebuild_project" {
  name         = var.codebuild_project_name
  description  = "Sana CodeBuild project"
  service_role = aws_iam_role.codebuild_role.arn

  logs_config {
    cloudwatch_logs {
      group_name  = "my-codebuild-logs"
      stream_name = "my-codebuild-stream"
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.codebuild_configuration["cb_compute_type"]
    image           = var.codebuild_configuration["cb_image"]
    type            = var.codebuild_configuration["cb_type"]
    privileged_mode = false

  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file(var.buildspec_file)
  }

  tags = merge(var.tags, {
    Name = "CodeBuildProject"
  })
}

resource "aws_codepipeline" "my_app_pipeline" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {

    location = aws_s3_bucket.sana-pipeline-bucket.bucket
    type     = "S3"
  }

  stage {
    name = var.codepipeline_stages["source"]

    action {
      name     = "SourceAction"
      category = "Source"
      owner    = var.codepipeline_owner
      provider = "ECR"
      version  = "1"

      output_artifacts = [var.codepipeline_artifacts["source"]]

      configuration = {
        RepositoryName = data.aws_ecr_repository.existing_repo.name
        ImageTag       = var.source_imgtag
      }
    }
  }

  stage {
    name = var.codepipeline_stages["build"]

    action {
      name     = "BuildAction"
      category = "Build"
      owner    = var.codepipeline_owner
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = [var.codepipeline_artifacts["source"]]
      output_artifacts = [var.codepipeline_artifacts["build"]]

      configuration = {
        ProjectName   = aws_codebuild_project.api_codebuild_project.arn
        PrimarySource = "source"
        EnvironmentVariables = jsonencode([
          {
            name  = "ECR_REPO_URL"
            value = data.aws_ecr_repository.existing_repo.repository_url
          },
          {
            name  = "ROLE"
            value = aws_iam_role.ecs_execution_role.arn
          },
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
        ])
      }
    }
  }

  stage {
    name = var.codepipeline_stages["deploy"]
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = var.codepipeline_owner
      provider        = "CodeDeployToECS"
      version         = "1"
      run_order       = 1
      input_artifacts = [var.codepipeline_artifacts["build"]]

      configuration = {
        ApplicationName                = aws_codedeploy_app.codedeploy_app.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.my_deployment_group.deployment_group_name
        TaskDefinitionTemplateArtifact = var.codepipeline_artifacts["build"]
        TaskDefinitionTemplatePath     = var.taskdef_name
        AppSpecTemplateArtifact        = var.codepipeline_artifacts["build"]
        AppSpecTemplatePath            = var.appspec_name
      }
    }
  }

  tags = merge(var.tags, {
    Name = "CodePipeline"
  })
}
