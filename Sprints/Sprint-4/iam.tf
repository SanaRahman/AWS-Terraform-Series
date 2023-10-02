resource "aws_iam_role" "codepipeline_role" {
  name = "my-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "MyCodePipelineRole"
  })
}

resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "codedeploy.amazonaws.com",
      },
    }],
  })

  tags = merge(var.tags, {
    Name = "MyCodeDeployRole"
  })
}

resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "MyCodeBuildRole"
  })
}

resource "aws_iam_policy" "iam_pass_policy" {
  name = "EcsPassPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "iam:PassRole",
        Effect   = "Allow",
        Resource = aws_iam_role.ecs_execution_role.arn
      },
    ]
  })

  tags = merge(var.tags, {
    Name = "MyIamPassPolicy"
  })
}

resource "aws_iam_policy_attachment" "attach_iam_pass_policy" {
  name       = "iam_pass_policy_attachment"
  roles      = [aws_iam_role.codebuild_role.name, aws_iam_role.codedeploy_role.name, aws_iam_role.codepipeline_role.name]
  policy_arn = aws_iam_policy.iam_pass_policy.arn
}

resource "aws_iam_policy_attachment" "s3_access" {
  name       = "s3-access"
  roles      = [aws_iam_role.codebuild_role.name, aws_iam_role.codedeploy_role.name, aws_iam_role.codepipeline_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy" "ecs_taskset_policies" {
  name = "EcsTaskSetPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { //required by codepipeline and codebuild
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateServicePrimaryTaskSet",
          "ecs:CreateTaskSet",
          "ecs:DeleteTaskSet",
          "ecs:DescribeServices",
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })

  tags = merge(var.tags, {
    Name = "MyECSTasksetPolicies"
  })
}

resource "aws_iam_policy_attachment" "attach_esc_task_policies" {
  name       = "ecstask_policies"
  roles      = [aws_iam_role.codebuild_role.name, aws_iam_role.codepipeline_role.name]
  policy_arn = aws_iam_policy.ecs_taskset_policies.arn
}

resource "aws_iam_policy" "deploy_policies" {
  name = "DeployementPolicies"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { //required by codepipeline and codedeploy
        Action = [
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
    ]
  })

  tags = merge(var.tags, {
    Name = "CodeDeployPPolicies"
  })
}

resource "aws_iam_policy_attachment" "attach_deploy_policies" {
  name       = "codedeploy-polices"
  roles      = [aws_iam_role.codepipeline_role.name, aws_iam_role.codebuild_role.name]
  policy_arn = aws_iam_policy.deploy_policies.arn
}

resource "aws_iam_policy" "codepipeline_policies" {
  name = "CodePipelinePermissions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"],
        Effect   = "Allow",
        Resource = aws_codebuild_project.api_codebuild_project.arn
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "MyCodePipelinePolicies"
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policies_attachment" {
  policy_arn = aws_iam_policy.codepipeline_policies.arn
  role       = aws_iam_role.codepipeline_role.name
}

resource "aws_iam_policy" "codedeploy_policies" {
  name = "CodedeployPermissions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:ModifyListener",
        ],
        Resource = "*"
      },
      {
        Action = [
          "ecs:CreateTaskSet",
          "ecs:UpdateService",
          "ecs:DeleteTaskSet",
          "ecs:DescribeServices"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "MyCodeBuildPolicies"
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_policies_attachment" {
  policy_arn = aws_iam_policy.codedeploy_policies.arn
  role       = aws_iam_role.codedeploy_role.name
}

resource "aws_iam_policy" "codebuild_policies" {
  name = "CodeBuildPermissions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      },

    ]
  })

  tags = merge(var.tags, {
    Name = "CodeBuildPolicy"
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policies_attachment" {
  policy_arn = aws_iam_policy.codebuild_policies.arn
  role       = aws_iam_role.codebuild_role.name
}

resource "aws_iam_policy_attachment" "codebuild_role_policy_attachment" {
  name       = "CodeBuildRolePolicyAttachment"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_s3_bucket_policy" "pipeline-bucket_policy" {
  bucket = aws_s3_bucket.sana-pipeline-bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCodePipeline",
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = "${aws_s3_bucket.sana-pipeline-bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_policy" {
  name = var.ecr_iam_policy_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      "Effect" : "Allow",
      "Action" : [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
      ],
      "Resource" : "*"
    }],
  })

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
