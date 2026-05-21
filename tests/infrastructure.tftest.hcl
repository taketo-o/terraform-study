############################
# Test Variables
############################

# terraform test 実行時に使用するテスト用変数
# variables.tf で定義した変数へ値を渡している
variables {

  # RDSマスターユーザー名
  db_username = "testuser"

  # RDSマスターパスワード
  db_password = "TestPass123!"

  # SNS通知送信先メールアドレス
  notification_email = "test@example.com"

  # EC2へSSH接続するためのKey Pair名
  key_pair_name = "test-key"

  # SSH秘密鍵パス
  # テスト用ダミーパス
  ssh_private_key_path = "/tmp/dummy.pem"
}

############################
# VPC Tests
############################

# VPC設定のテスト
run "validate_vpc" {

  # terraform plan を実行して検証
  command = plan

  # アサーション(検証条件)
  assert {

    # VPC CIDRが期待値か確認
    condition = aws_vpc.main.cidr_block == "10.0.0.0/16"

    # 条件不一致時のエラーメッセージ
    error_message = "VPC CIDR block must be 10.0.0.0/16"
  }
}

############################
# EC2 Tests
############################

# EC2インスタンスタイプ検証
run "validate_ec2" {

  # plan実行
  command = plan

  assert {

    # output.tf の値を検証
    condition = output.ec2_instance_type == "t2.small"

    # エラー時メッセージ
    error_message = "EC2 instance type must be t2.small"
  }
}

# EC2 SSH制限テスト
# SSHが全世界公開されていないか確認
run "validate_ec2_ssh_restriction" {

  # plan実行
  command = plan

  assert {

    # ingressルール内に
    # 0.0.0.0/0 が存在しないことを確認
    condition = !contains(
      flatten([

        # EC2 Security Group の ingress一覧を走査
        for rule in aws_security_group.ec2.ingress :

        # cidr_blocks を取得
        rule.cidr_blocks
      ]),

      # 検索対象
      "0.0.0.0/0"
    )

    # エラーメッセージ
    error_message = "EC2 SSH must not be open to the world"
  }
}

############################
# RDS Tests
############################

# RDSエンジン検証
run "validate_rds" {

  # plan実行
  command = plan

  assert {

    # MySQLであることを確認
    condition = output.rds_engine == "mysql"

    # エラーメッセージ
    error_message = "RDS engine must be MySQL"
  }
}

############################
# ALB Tests
############################

# ALBタイプ検証
run "validate_alb" {

  # plan実行
  command = plan

  assert {

    # application load balancer であること確認
    condition = output.alb_type == "application"

    # エラーメッセージ
    error_message = "ALB must be application load balancer"
  }
}

# ALBがインターネット公開か確認
run "validate_alb_public" {

  # plan実行
  command = plan

  assert {

    # internal=false ならインターネット公開ALB
    condition = aws_lb.main.internal == false

    # エラーメッセージ
    error_message = "ALB must be internet-facing"
  }
}

# ALB Security GroupにSSH許可が無いか確認
run "validate_alb_no_ssh" {

  # plan実行
  command = plan

  assert {

    # ingressルールの中から
    # 22番ポート許可ルールを抽出
    condition = length([
      for rule in aws_security_group.alb.ingress :

      # SSHポートのみ抽出
      rule if rule.from_port == 22

      # SSHルール数が0であることを確認
    ]) == 0

    # エラーメッセージ
    error_message = "ALB security group must not allow SSH"
  }
}

# ALB Target Groupポート確認
run "validate_springboot_port" {

  # plan実行
  command = plan

  assert {

    # Spring Boot用8080番ポート確認
    condition = aws_lb_target_group.app.port == 8080

    # エラーメッセージ
    error_message = "Target group must use port 8080"
  }
}

############################
# WAF Tests
############################

# WAF Scope確認
run "validate_waf" {

  # plan実行
  command = plan

  assert {

    # REGIONAL WAFであること確認
    condition = output.waf_scope == "REGIONAL"

    # エラーメッセージ
    error_message = "WAF scope must be REGIONAL"
  }
}