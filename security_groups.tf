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

  # インバウンド通信設定
  ingress {

    # 開始ポート
    from_port = 80

    # 終了ポート
    to_port = 80

    # TCP通信
    protocol = "tcp"

    # 全世界からアクセス許可
    # HTTP公開用
    cidr_blocks = ["0.0.0.0/0"]
  }

  # アウトバウンド通信設定
  egress {

    # 全ポート許可
    from_port = 0
    to_port   = 0

    # -1 = 全プロトコル
    protocol = "-1"

    # 全宛先への通信許可
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2用セキュリティグループ
# SSH接続とALBからのアプリ通信を許可
resource "aws_security_group" "ec2" {

  # セキュリティグループ名
  name = "ec2-sg"

  # 説明
  description = "EC2 Security Group"

  # 所属VPC
  vpc_id = aws_vpc.main.id

  # SSH接続許可
  ingress {

    # SSHポート
    from_port = 22
    to_port   = 22

    # TCP通信
    protocol = "tcp"

    # 特定IPのみSSH許可
    # /32 = 単一IP指定
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  # Spring Bootアプリ用ポート
  # ALBからの通信のみ許可
  ingress {

    # Spring Boot待受ポート
    from_port = 8080
    to_port   = 8080

    # TCP通信
    protocol = "tcp"

    # ALBセキュリティグループからの通信のみ許可
    security_groups = [aws_security_group.alb.id]
  }

  # EC2から外部への通信許可
  egress {

    # 全ポート
    from_port = 0
    to_port   = 0

    # 全プロトコル
    protocol = "-1"

    # 全宛先許可
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS用セキュリティグループ
# EC2からのMySQL接続のみ許可
resource "aws_security_group" "rds" {

  # セキュリティグループ名
  name = "rds-sg"

  # 説明
  description = "RDS Security Group"

  # 所属VPC
  vpc_id = aws_vpc.main.id

  # MySQL接続許可
  ingress {

    # MySQLポート
    from_port = 3306
    to_port   = 3306

    # TCP通信
    protocol = "tcp"

    # EC2セキュリティグループからのみ接続許可
    # 外部から直接DB接続できない構成
    security_groups = [aws_security_group.ec2.id]
  }

  # RDSから外部への通信許可
  egress {

    # 全ポート
    from_port = 0
    to_port   = 0

    # 全プロトコル
    protocol = "-1"

    # 全宛先許可
    cidr_blocks = ["0.0.0.0/0"]
  }
}