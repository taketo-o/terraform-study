############################
# CloudWatch Alarms
############################

# EC2のCPU使用率監視アラーム
# CPU使用率が高すぎる場合に通知する
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {

  # CloudWatch Alarm名
  alarm_name = "EC2CPUAlarm"

  # アラームの説明
  alarm_description = "EC2 CPU > 80%"

  # しきい値との比較条件
  # GreaterThanThreshold = 閾値を超えたらアラーム
  comparison_operator = "GreaterThanThreshold"

  # 何回連続で条件を満たしたらアラームにするか
  # 2回連続で閾値超過したらALARM状態
  evaluation_periods = 2

  # 監視対象メトリクス
  # CPU使用率
  metric_name = "CPUUtilization"

  # EC2関連メトリクスの名前空間
  namespace = "AWS/EC2"

  # 監視間隔(秒)
  # 300秒 = 5分
  period = 300

  # 統計方法
  # Average = 平均値
  statistic = "Average"

  # 閾値
  # CPU使用率80%以上でアラーム対象
  threshold = 80

  # どのEC2を監視するか指定
  dimensions = {

    # SpringBoot EC2インスタンスID
    InstanceId = aws_instance.springboot.id
  }

  # アラーム発生時に実行するアクション
  # SNS通知を送信
  alarm_actions = [aws_sns_topic.alarm.arn]
}

# EC2のステータスチェック失敗監視
# インスタンス障害やOS異常を検知する
resource "aws_cloudwatch_metric_alarm" "ec2_status" {

  # アラーム名
  alarm_name = "EC2StatusCheckAlarm"

  # 説明
  alarm_description = "EC2 Status Check Failed"

  # 閾値以上ならアラーム
  # 1以上でアラーム発火
  comparison_operator = "GreaterThanOrEqualToThreshold"

  # 1回でも異常なら即アラーム
  evaluation_periods = 1

  # ステータスチェック失敗メトリクス
  metric_name = "StatusCheckFailed"

  # EC2メトリクス名前空間
  namespace = "AWS/EC2"

  # 監視間隔
  # 60秒ごと
  period = 60

  # 最大値で判定
  # 1が出た時点で異常検知
  statistic = "Maximum"

  # 閾値
  threshold = 1

  # 監視対象EC2
  dimensions = {

    # SpringBoot EC2
    InstanceId = aws_instance.springboot.id
  }

  # アラーム時にSNS通知
  alarm_actions = [aws_sns_topic.alarm.arn]
}

# ALBの5xxエラー監視
# ALB側でサーバエラーが多発した場合に通知
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {

  # アラーム名
  alarm_name = "ALB5XXAlarm"

  # 説明
  alarm_description = "ALB 5XX Errors"

  # 閾値超過でアラーム
  comparison_operator = "GreaterThanThreshold"

  # 1回の監視で閾値超過したらアラーム
  evaluation_periods = 1

  # ALBの5xxエラーメトリクス
  metric_name = "HTTPCode_ELB_5XX_Count"

  # ALB関連の名前空間
  namespace = "AWS/ApplicationELB"

  # 監視間隔
  # 5分
  period = 300

  # 合計値で判定
  # 5分間のエラー総数を見る
  statistic = "Sum"

  # しきい値
  # 5分間で10件超えたらアラーム
  threshold = 10

  # どのALBを監視するか指定
  dimensions = {

    # ALB識別子
    # arn_suffix はCloudWatch用識別子として必要
    LoadBalancer = aws_lb.main.arn_suffix
  }

  # アラーム時にSNS通知
  alarm_actions = [aws_sns_topic.alarm.arn]
}