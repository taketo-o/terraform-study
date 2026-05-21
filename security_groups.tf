############################
# Security Groups
############################

# ALB用セキュリティグループ
# インターネットからのHTTPアクセスを許可
resource "aws_security_group" "alb" {

  # セキュリティグループ名
  name = "alb-sg"

  # 説明
  description = "ALB Security Group"

  # 所属VPC
  vpc_id = aws_vpc.main.id

  ############################
  # Inbound Rules (Ingress)
  ############################

  # HTTP(80)を全世界から許可
  ingress {

    # ポート範囲開始
    from_port = 80

    # ポート範囲終了
    to_port = 80

    # TCP通信
    protocol = "tcp"

    # 0.0.0.0/0 = インターネット全体
    cidr_blocks = ["0.0.0.0/0"]
  }

  ############################
  # Outbound Rules (Egress)
  ############################

  # 全アウトバウンド通信許可
  egress {

    # 全ポート
    from_port = 0
    to_port   = 0

    # 全プロトコル許可
    protocol = "-1"

    # 全宛先許可
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# EC2 Security Group
############################

# EC2用セキュリティグループ
# SSH + ALB経由のアプリ通信を許可
resource "aws_security_group" "ec2" {

  name        = "ec2-sg"
  description = "EC2 Security Group"
  vpc_id      = aws_vpc.main.id

  ############################
  # SSH Ingress
  ############################

  # SSHアクセス許可（特定IPのみ）
  ingress {

    # SSHポート
    from_port = 22
    to_port   = 22

    # TCP通信
    protocol = "tcp"

    # 自分のIPのみ許可
    # chomp(data.http.myip.response_body) で動的取得
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ############################
  # Application Ingress
  ############################

  # Spring Bootアプリ(8080)
  # ALBからの通信のみ許可
  ingress {

    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"

    # ALBセキュリティグループからのみ許可
    security_groups = [aws_security_group.alb.id]
  }

  ############################
  # Outbound Rules
  ############################

  egress {

    # 全ポート許可
    from_port = 0
    to_port   = 0

    # 全プロトコル許可
    protocol = "-1"

    # 全宛先許可
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# RDS Security Group
############################

# RDS用セキュリティグループ
# DBへの直接外部アクセスを遮断
resource "aws_security_group" "rds" {

  name        = "rds-sg"
  description = "RDS Security Group"
  vpc_id      = aws_vpc.main.id

  ############################
  # MySQL Ingress
  ############################

  # MySQL(3306)をEC2からのみ許可
  ingress {

    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    # EC2 SGからのみ許可
    # インターネットから直接DB接続不可
    security_groups = [aws_security_group.ec2.id]
  }

  ############################
  # Outbound Rules
  ############################

  egress {

    # 全通信許可
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}