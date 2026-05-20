############################
# ALB
############################

# Application Load Balancer(ALB)を作成するリソース
# 外部からのHTTPリクエストを受け取り、EC2へ振り分ける役割
resource "aws_lb" "main" {

  # ALBの名前
  name = "springboot-alb"

  # false = インターネット公開ALB
  # true にすると内部通信用(private ALB)
  internal = false

  # Application Load Balancer を使用
  # HTTP/HTTPS通信を扱うロードバランサ
  load_balancer_type = "application"

  # ALBに適用するセキュリティグループ
  # HTTP(80)などの通信許可を設定しているSGを関連付け
  security_groups = [aws_security_group.alb.id]

  # ALBを配置するサブネット
  # ALBは冗長化のため2つ以上のAZに配置するのが一般的
  subnets = [

    # ap-northeast-1a のパブリックサブネット
    aws_subnet.public_1a.id,

    # ap-northeast-1c のパブリックサブネット
    aws_subnet.public_1c.id
  ]
}

# ALBがリクエストを転送する先(Target Group)を作成
resource "aws_lb_target_group" "app" {

  # Target Group名
  name = "springboot-tg"

  # EC2側で待ち受けるポート
  # Spring Bootが8080番で起動している想定
  port = 8080

  # 通信プロトコル
  protocol = "HTTP"

  # このTarget Groupを所属させるVPC
  vpc_id = aws_vpc.main.id

  # ヘルスチェック設定
  # ALBがEC2の正常性確認を行う
  health_check {

    # "/" にアクセスして200系レスポンスが返れば正常判定
    path = "/"
  }
}

# Target Group に EC2インスタンスを登録
# ALB → EC2 の接続先を定義している
resource "aws_lb_target_group_attachment" "ec2" {

  # どのTarget Groupに登録するか
  target_group_arn = aws_lb_target_group.app.arn

  # 登録対象のEC2インスタンスID
  target_id = aws_instance.springboot.id

  # EC2側の待受ポート
  port = 8080
}

# ALB Listener設定
# ALBがどのポートでリクエストを受けるかを定義
resource "aws_lb_listener" "http" {

  # 対象のALB
  load_balancer_arn = aws_lb.main.arn

  # HTTPの80番ポートで待受
  port = 80

  # HTTP通信を使用
  protocol = "HTTP"

  # 受信したリクエストの転送ルール
  default_action {

    # forward = Target Groupへ転送
    type = "forward"

    # 転送先Target Group
    target_group_arn = aws_lb_target_group.app.arn
  }
}