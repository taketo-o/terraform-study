############################
# SNS
############################

# SNS Topicを作成
# CloudWatch Alarmなどの通知先として利用する
resource "aws_sns_topic" "alarm" {

  # SNS Topic名
  # 通知グループのような役割
  name = "cloudwatch-alarm-topic"
}

# SNSのサブスクリプション設定
# Topicへ届いた通知をどこへ送るか定義する
resource "aws_sns_topic_subscription" "email" {

  # どのSNS Topicを使用するか指定
  topic_arn = aws_sns_topic.alarm.arn

  # 通知方式
  # email = メール通知
  protocol = "email"

  # 通知送信先メールアドレス
  # terraform.tfvarsなどから変数で受け取る
  endpoint = var.notification_email
}