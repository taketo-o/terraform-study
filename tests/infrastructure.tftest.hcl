run "validate_vpc" {
  command = plan

  variables {
  db_username        = "testuser"
  db_password        = "TestPass123!"
  notification_email = "test@example.com"
  key_pair_name      = "test-key"
}

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block must be 10.0.0.0/16"
  }
}

run "validate_ec2" {
  command = plan

  assert {
    condition     = aws_instance.springboot.instance_type == "t2.small"
    error_message = "EC2 instance type must be t2.small"
  }
}

run "validate_rds" {
  command = plan

  assert {
    condition     = aws_db_instance.mysql.engine == "mysql"
    error_message = "RDS engine must be MySQL"
  }
}

run "validate_alb" {
  command = plan

  assert {
    condition     = aws_lb.main.load_balancer_type == "application"
    error_message = "ALB must be application load balancer"
  }
}

run "validate_waf" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl.main.scope == "REGIONAL"
    error_message = "WAF scope must be REGIONAL"
  }
}