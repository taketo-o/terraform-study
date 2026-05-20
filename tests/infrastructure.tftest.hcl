variables {
  db_username          = "testuser"
  db_password          = "TestPass123!"
  notification_email   = "test@example.com"
  key_pair_name        = "test-key"
  ssh_private_key_path = "/tmp/dummy.pem"
}

run "validate_vpc" {
  command = plan

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block must be 10.0.0.0/16"
  }
}

run "validate_ec2" {
  command = plan

  assert {
    condition     = output.ec2_instance_type == "t2.small"
    error_message = "EC2 instance type must be t2.small"
  }
}

run "validate_rds" {
  command = plan

  assert {
    condition     = output.rds_engine == "mysql"
    error_message = "RDS engine must be MySQL"
  }
}

run "validate_alb" {
  command = plan

  assert {
    condition     = output.alb_type == "application"
    error_message = "ALB must be application load balancer"
  }
}

run "validate_waf" {
  command = plan

  assert {
    condition     = output.waf_scope == "REGIONAL"
    error_message = "WAF scope must be REGIONAL"
  }
}

run "validate_ec2_ssh_restriction" {
  command = plan

  assert {
    condition = !contains(
      flatten([
        for rule in aws_security_group.ec2.ingress :
        rule.cidr_blocks
      ]),
      "0.0.0.0/0"
    )
    error_message = "EC2 SSH must not be open to the world"
  }
}

run "validate_alb_public" {
  command = plan

  assert {
    condition     = aws_lb.main.internal == false
    error_message = "ALB must be internet-facing"
  }
}

run "validate_alb_no_ssh" {
  command = plan

  assert {
    condition = length([
      for rule in aws_security_group.alb.ingress :
      rule if rule.from_port == 22
    ]) == 0
    error_message = "ALB security group must not allow SSH"
  }
}

run "validate_springboot_port" {
  command = plan

  assert {
    condition     = aws_lb_target_group.app.port == 8080
    error_message = "Target group must use port 8080"
  }
} 