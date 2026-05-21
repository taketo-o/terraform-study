############################
# RDS
############################

# RDS用のDB Subnet Groupを作成
# RDSをどのサブネットに配置するか定義する
resource "aws_db_subnet_group" "main" {

  # DB Subnet Group名
  name = "main-db-subnet-group"

  # RDSを配置するサブネット一覧
  # 通常はプライベートサブネットを使用する
  subnet_ids = [

    # ap-northeast-1a のプライベートサブネット
    aws_subnet.private_1a.id,

    # ap-northeast-1c のプライベートサブネット
    aws_subnet.private_1c.id
  ]

  # AWSコンソール用タグ
  tags = {

    # 表示名
    Name = "Main DB subnet group"
  }
}

# MySQLのRDSインスタンスを作成
resource "aws_db_instance" "mysql" {

  # ストレージ容量(GB)
  allocated_storage = 20

  # DBエンジン
  # MySQLを使用
  engine = "mysql"

  # RDSインスタンスタイプ
  # 小規模向けARMベースインスタンス
  instance_class = "db.t4g.micro"

  # 初期作成されるDB名
  db_name = "awsstudy"

  # DBログインユーザー名
  # 変数(terraform.tfvarsなど)から受け取る
  username = var.db_username

  # DBパスワード
  # セキュリティ上、変数管理が一般的
  password = var.db_password

  # false = 外部公開しない
  # インターネットから直接アクセス不可
  publicly_accessible = false

  # 自動バックアップ保持日数
  # 7日間バックアップ保存
  backup_retention_period = 7

  # Multi-AZ構成
  # false = 単一AZ構成
  # true にすると高可用性構成になる
  multi_az = false

  # RDSへ適用するセキュリティグループ
  # MySQL(3306)許可などを設定している想定
  vpc_security_group_ids = [aws_security_group.rds.id]

  # 使用するDB Subnet Group
  # プライベートサブネットへRDSを配置
  db_subnet_group_name = aws_db_subnet_group.main.name

  # RDS削除時に最終スナップショットを作成しない
  # 学習用途では便利だが、本番では通常false推奨
  skip_final_snapshot = true
}