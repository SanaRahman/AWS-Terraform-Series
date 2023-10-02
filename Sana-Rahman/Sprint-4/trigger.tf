resource "aws_cloudwatch_event_rule" "image_push" {
  name     = "ecr_image_push"
  role_arn = aws_iam_role.cwe_role.arn

  event_pattern = <<EOF
{
  "source": [
    "aws.ecr"
  ],
  "detail": {
    "action-type": [
      "PUSH"
    ],
    "image-tag": [
      "green"
    ],
    "repository-name": [
      "${var.ecr_repository_name}"
    ],
    "result": [
      "SUCCESS"
    ]
  },
  "detail-type": [
    "ECR Image Action"
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "codepipeline" {
  rule      = aws_cloudwatch_event_rule.image_push.name
  target_id = "${var.ecr_repository_name}-Image-Push-Codepipeline"
  arn       = aws_codepipeline.my_app_pipeline.arn
  role_arn  = aws_iam_role.cwe_role.arn
}


resource "aws_iam_role" "cwe_role" {
  name               = "cwe-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": ["events.amazonaws.com"]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "cwe_policy" {
  name = "cwe-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "codepipeline:StartPipelineExecution"
        ],
        "Resource": [
            "*"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "cws_policy_attachment" {

  name       = "cwe-policy"
  roles      = [aws_iam_role.cwe_role.name]
  policy_arn = aws_iam_policy.cwe_policy.arn
}
