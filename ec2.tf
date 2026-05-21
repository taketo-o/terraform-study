############################
# EC2
############################

# EC2インスタンスを作成するリソース
# Spring Bootアプリケーションを動かすサーバ
resource "aws_instance" "springboot" {

  # 使用するAMI(Amazon Machine Image)
  # EC2起動時のOSテンプレート
  # Amazon Linux 2023 などのイメージIDが入る
  ami = "ami-0f18986364089c4ab"

  # EC2インスタンスタイプ
  # CPU・メモリ性能を決める
  # t2.small = 2GBメモリのバースト型インスタンス
  instance_type = "t2.small"

  # SSH接続に使用するキーペア名
  # terraform.tfvars などから変数で受け取る
  key_name = var.key_pair_name

  # EC2を配置するサブネット
  # public_1a に配置しているためパブリックサブネット構成
  subnet_id = aws_subnet.public_1a.id

  # EC2へ適用するセキュリティグループ
  # SSHや8080番ポート許可などを定義している想定
  vpc_security_group_ids = [aws_security_group.ec2.id]

  # AWSコンソール上で付与されるタグ
  tags = {

    # EC2インスタンス名
    Name = "SpringBootServer"
  }
}