#####################################################
# outputs.tf
#####################################################

# ALBのDNS名を出力
# terraform apply 完了後に表示される
# ブラウザアクセス時に使用できる
output "alb_dns_name" {

  # Outputの説明
  description = "ALB DNS Name"

  # 出力する値
  # ALBのDNS名
  value = aws_lb.main.dns_name
}

# WAF WebACLのARNを出力
# AWSリソース識別子として利用できる
output "web_acl_arn" {

  # Output説明
  description = "WAF WebACL ARN"

  # WAF WebACLのARN
  value = aws_wafv2_web_acl.main.arn
}

# SNS TopicのARNを出力
# CloudWatch Alarm通知先確認などに利用
output "sns_topic_arn" {

  # Output説明
  description = "SNS Topic ARN"

  # SNS Topic ARN
  value = aws_sns_topic.alarm.arn
}

# EC2インスタンスタイプを出力
# どのスペックで作成されたか確認できる
output "ec2_instance_type" {

  # EC2のインスタンスタイプ
  value = aws_instance.springboot.instance_type
}

# ALBタイプを出力
# application か network か確認可能
output "alb_type" {

  # Load Balancerタイプ
  value = aws_lb.main.load_balancer_type
}

# RDSのDBエンジンを出力
# mysql / postgres などを確認できる
output "rds_engine" {

  # RDSエンジン名
  value = aws_db_instance.mysql.engine
}

# WAF Scopeを出力
# REGIONAL or CLOUDFRONT を確認できる
output "waf_scope" {

  # WAFの適用範囲
  value = aws_wafv2_web_acl.main.scope
}

# EC2のパブリックIPを出力
# SSH接続などに利用
output "ec2_public_ip" {

  # Output説明
  description = "EC2 Public IP Address"

  # EC2のPublic IP
  value = aws_instance.springboot.public_ip
}