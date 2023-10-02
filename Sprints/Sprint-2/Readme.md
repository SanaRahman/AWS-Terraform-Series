# AWS Infrastructure Deployment using Terraform

This repository contains Terraform configuration for deploying an AWS infrastructure that includes a VPC, subnets, security groups, an RDS cluster, an EC2 instance, and related resources.

## Prerequisites

- Terraform CLI installed. [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- AWS account and AWS CLI configured.
- Basic understanding of Terraform and AWS services.

# VPC Creation and Network Setup

This repository contains the necessary code to set up a Virtual Private Cloud (VPC) in AWS, along with subnets, routing, and gateway configurations. This environment is designed for a project named "Sprint 2," created by Sana Rahman.

## Overview

This setup involves creating the following components:

1. **VPC**: The core networking component, providing isolated virtual network environments.
2. **Subnets**: Dividing the VPC into isolated sections for public and private resources.
3. **Gateway**: Establishing internet access via an internet gateway and NAT gateway.
4. **Route Tables**: Configuring routing for traffic within the VPC and to external networks.
5. **Security Groups**: Defining firewall rules for EC2 instances and RDS instances.
6. **Aurora Serverless Database**: Setting up a PostgreSQL database cluster in a serverless configuration.
7. **EC2 Instance and ECR Repo**: Launching an EC2 instance and using a Docker container from an Elastic Container Repository (ECR).
8. **Monitoring**: Utilizing CloudWatch Dashboards and Alarms to monitor EC2 instances.

## Instructions

To set up and deploy this environment, follow these steps:

1. Clone this repository to your local machine.
2. Install Terraform on your machine.
3. Navigate to the cloned directory using the command line.
4. Run `terraform init` to initialize the Terraform configuration.
5. Customize the variables in `variables.tf` to match your requirements.
6. Run `terraform plan` to review the changes that will be applied.
7. If the plan looks good, execute `terraform apply` to create the infrastructure.
8. Once the setup is complete, you will receive outputs like the RDS endpoint and EC2 instance details.

**Important**: Make sure to review the code and variables to ensure they align with your security and networking requirements.

## Cleanup

To avoid incurring costs, it's important to clean up the resources when they're no longer needed. To do this, run:

```bash
terraform destroy
```

## Architecture diagram
![Alt text](<arch.png>)


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_public_ecr"></a> [public\_ecr](#module\_public\_ecr) | ./modules/ecr | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_dashboard.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_log_group.api_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.backend_4xx_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_db_subnet_group.subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_ecr_repository.ecr_repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_eip.eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.ec2_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ecr_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecr_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecr_role_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.my_ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_rds_cluster.aurora_postgresql](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.aurora_postgresql_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_route_table.my_private_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.my_public_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_subnet_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_subnet_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_secretsmanager_secret.database_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.database_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.ec2_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.rds_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sns_topic.sms_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.sms_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_subnet.private_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnet2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.my_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_ami.amzn-linux-2023-ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_rds_cluster.rds_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arora_engine_v"></a> [arora\_engine\_v](#input\_arora\_engine\_v) | Arora Engine Version | `string` | `"13.6"` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS account ID | `string` | `"435495016122"` | no |
| <a name="input_backend_port"></a> [backend\_port](#input\_backend\_port) | backend ports for ec2 | `number` | `5000` | no |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | Public CIDR Block | `string` | `"0.0.0.0/0"` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Database name for RDS cluster | `string` | n/a | yes |
| <a name="input_database_secret_name"></a> [database\_secret\_name](#input\_database\_secret\_name) | Name of the secret in Secrets Manager | `string` | n/a | yes |
| <a name="input_ecr_repo_name"></a> [ecr\_repo\_name](#input\_ecr\_repo\_name) | ECr repo name | `string` | n/a | yes |
| <a name="input_egress_cidr_blocks"></a> [egress\_cidr\_blocks](#input\_egress\_cidr\_blocks) | TCP egress CIDR blocks | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_egress_port"></a> [egress\_port](#input\_egress\_port) | TCP egress to port | `number` | `0` | no |
| <a name="input_egress_protocol"></a> [egress\_protocol](#input\_egress\_protocol) | TCP egress protocol | `string` | `"tcp"` | no |
| <a name="input_email"></a> [email](#input\_email) | User email address to send notification in case of an alert. | `string` | `"sanarahmna930@gmail.com"` | no |
| <a name="input_frontend_port"></a> [frontend\_port](#input\_frontend\_port) | frontend port for ec2 | `number` | `3000` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of EC2 instance to launch | `string` | `"t2.micro"` | no |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | Master password for RDS cluster | `string` | n/a | yes |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Master username for RDS cluster | `string` | n/a | yes |
| <a name="input_private_subnet1_ava_zone"></a> [private\_subnet1\_ava\_zone](#input\_private\_subnet1\_ava\_zone) | Availability zone for private subnet 1 | `string` | `"ap-southeast-1b"` | no |
| <a name="input_private_subnet1_cidr_block"></a> [private\_subnet1\_cidr\_block](#input\_private\_subnet1\_cidr\_block) | CIDR block for private subnet 1 | `string` | `"15.0.2.0/24"` | no |
| <a name="input_private_subnet2_ava_zone"></a> [private\_subnet2\_ava\_zone](#input\_private\_subnet2\_ava\_zone) | Availability zone for private subnet 2 | `string` | `"ap-southeast-1c"` | no |
| <a name="input_private_subnet2_cidr_block"></a> [private\_subnet2\_cidr\_block](#input\_private\_subnet2\_cidr\_block) | CIDR block for private subnet 2 | `string` | `"15.0.3.0/24"` | no |
| <a name="input_public_key_path"></a> [public\_key\_path](#input\_public\_key\_path) | Path to the public key file | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_public_subnet_ava_zone"></a> [public\_subnet\_ava\_zone](#input\_public\_subnet\_ava\_zone) | Availability zone for the public subnet | `string` | `"ap-southeast-1a"` | no |
| <a name="input_public_subnet_cidr_block"></a> [public\_subnet\_cidr\_block](#input\_public\_subnet\_cidr\_block) | CIDR block for the public subnet | `string` | `"15.0.1.0/24"` | no |
| <a name="input_rds_cluster_instance_class"></a> [rds\_cluster\_instance\_class](#input\_rds\_cluster\_instance\_class) | The RDS instance class for the Aurora cluster | `string` | `"db.t2.small"` | no |
| <a name="input_rds_port"></a> [rds\_port](#input\_rds\_port) | RDS ingress to port | `number` | `5432` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be provisioned | `string` | `"ap-southeast-1"` | no |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | SSH ingress from port | `number` | `22` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | <pre>{<br>  "Creator": "Sana Rahman",<br>  "Name": "Default_Name",<br>  "Project": "Sprint 2"<br>}</pre> | no |
| <a name="input_user_data_path"></a> [user\_data\_path](#input\_user\_data\_path) | Path to user data file | `string` | `"user_data_script.sh"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC | `string` | `"15.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dashboard_url"></a> [dashboard\_url](#output\_dashboard\_url) | CloudWatch dashboard URL |
| <a name="output_ec2_instance_id"></a> [ec2\_instance\_id](#output\_ec2\_instance\_id) | EC2 instance ID |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | CloudWatch log group name |
| <a name="output_rds_cluster_endpoint"></a> [rds\_cluster\_endpoint](#output\_rds\_cluster\_endpoint) | Rds Endpoint |
| <a name="output_repo_url"></a> [repo\_url](#output\_repo\_url) | ECR Repository Url |
