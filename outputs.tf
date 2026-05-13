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

output "ec2_instance_type" {
  value = aws_instance.springboot.instance_type
}

output "alb_type" {
  value = aws_lb.main.load_balancer_type
}

output "rds_engine" {
  value = aws_db_instance.mysql.engine
}

output "waf_scope" {
  value = aws_wafv2_web_acl.main.scope
}
