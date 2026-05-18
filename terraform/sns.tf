############################
# SNS
############################
resource "aws_sns_topic" "alarm" {
  name = "cloudwatch-alarm-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = var.notification_email
}