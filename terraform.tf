#####################################################
# provider.tf
#####################################################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

#####################################################
# variables.tf
#####################################################
variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "notification_email" {
  description = "CloudWatch SNS notification email"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 Key Pair Name"
  type        = string
}

#####################################################
# main.tf
#####################################################

############################
# VPC
############################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "aws-study-vpc"
  }
}

############################
# Subnets
############################
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"
}

############################
# Internet Gateway
############################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

############################
# Route Table
############################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

############################
# Security Groups
############################
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2" {
  name        = "ec2-sg"
  description = "EC2 Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["118.9.136.138/32"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "RDS Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# EC2
############################
resource "aws_instance" "springboot" {
  ami                    = "ami-0f18986364089c4ab"
  instance_type          = "t2.small"
  key_name               = var.key_pair_name
  subnet_id              = aws_subnet.public_1a.id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  tags = {
    Name = "SpringBootServer"
  }
}

############################
# RDS
############################
resource "aws_db_subnet_group" "main" {
  name = "main-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]

  tags = {
    Name = "Main DB subnet group"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t4g.micro"
  db_name                = "awsstudy"
  username               = var.db_username
  password               = var.db_password
  publicly_accessible    = false
  backup_retention_period = 7
  multi_az               = false

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  skip_final_snapshot = true
}

############################
# ALB
############################
resource "aws_lb" "main" {
  name               = "springboot-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]
}

resource "aws_lb_target_group" "app" {
  name     = "springboot-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.springboot.id
  port             = 8080
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

############################
# SNS
############################
resource "aws_sns_topic" "alarm" {
  name = "cloudwatch-alarm-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

############################
# CloudWatch Alarms
############################
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "EC2CPUAlarm"
  alarm_description   = "EC2 CPU > 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    InstanceId = aws_instance.springboot.id
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_status" {
  alarm_name          = "EC2StatusCheckAlarm"
  alarm_description   = "EC2 Status Check Failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1

  dimensions = {
    InstanceId = aws_instance.springboot.id
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "ALB5XXAlarm"
  alarm_description   = "ALB 5XX Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
}

############################
# WAF
############################
resource "aws_wafv2_web_acl" "main" {
  name  = "MyWebACL"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "MyWebACLMetric"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWSManagedCommonRules"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRulesMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedKnownBadInputs"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputsMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedIPReputation"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPReputationMetric"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

#####################################################
# outputs.tf
#####################################################
output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = aws_lb.main.dns_name
}

output "web_acl_arn" {
  description = "WAF WebACL ARN"
  value       = aws_wafv2_web_acl.main.arn
}

output "sns_topic_arn" {
  description = "SNS Topic ARN"
  value       = aws_sns_topic.alarm.arn
}