# Obtain Route53 hosted zone data
data "aws_route53_zone" "hosted_zone" {
  name         = var.domain_name # Replace with your actual domain
  private_zone = false
}

data "aws_ecr_repository" "existing_repo" {
  name = var.ecr_repository_name
}
