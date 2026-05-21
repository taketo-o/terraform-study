############################
# WAF
############################

# WAF(Web Application Firewall)のWeb ACLを作成
# Webアプリケーションへの不正アクセスを防御する
resource "aws_wafv2_web_acl" "main" {

  # WAF名
  name = "MyWebACL"

  # 適用範囲
  # REGIONAL = ALBやAPI Gateway向け
  # CLOUDFRONTの場合はグローバル
  scope = "REGIONAL"

  # デフォルト動作
  # ルールに一致しない通信は許可
  default_action {
    allow {}
  }

  # CloudWatchメトリクス設定
  visibility_config {

    # CloudWatchメトリクス有効化
    cloudwatch_metrics_enabled = true

    # CloudWatch上のメトリクス名
    metric_name = "MyWebACLMetric"

    # サンプルリクエスト保存
    # WAFログ分析時に利用できる
    sampled_requests_enabled = true
  }

  # AWSマネージドルール(Common Rule Set)
  # 一般的なWeb攻撃を防御
  rule {

    # ルール名
    name = "AWSManagedCommonRules"

    # 優先順位
    # 数値が小さいほど先に評価される
    priority = 1

    # ルール一致時の動作
    # none = マネージドルールのデフォルト動作使用
    override_action {
      none {}
    }

    # ルール内容
    statement {

      # AWS提供マネージドルールを利用
      managed_rule_group_statement {

        # 提供元
        vendor_name = "AWS"

        # ルールセット名
        # SQLiやXSSなど一般的攻撃を防御
        name = "AWSManagedRulesCommonRuleSet"
      }
    }

    # CloudWatch設定
    visibility_config {

      # メトリクス有効化
      cloudwatch_metrics_enabled = true

      # メトリクス名
      metric_name = "CommonRulesMetric"

      # サンプルリクエスト保存
      sampled_requests_enabled = true
    }
  }

  # Known Bad Inputsルール
  # 悪意ある入力パターンを検知
  rule {

    # ルール名
    name = "AWSManagedKnownBadInputs"

    # 優先順位
    priority = 2

    # デフォルト動作使用
    override_action {
      none {}
    }

    # ルール定義
    statement {

      # AWSマネージドルール利用
      managed_rule_group_statement {

        # 提供元
        vendor_name = "AWS"

        # 不正入力検知ルール
        name = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    # CloudWatch設定
    visibility_config {

      # メトリクス有効化
      cloudwatch_metrics_enabled = true

      # メトリクス名
      metric_name = "KnownBadInputsMetric"

      # サンプル保存
      sampled_requests_enabled = true
    }
  }

  # IP Reputationルール
  # 悪質IPリストからのアクセスを検知
  rule {

    # ルール名
    name = "AWSManagedIPReputation"

    # 優先順位
    priority = 3

    # デフォルト動作利用
    override_action {
      none {}
    }

    # ルール定義
    statement {

      # AWSマネージドルール
      managed_rule_group_statement {

        # 提供元
        vendor_name = "AWS"

        # 悪質IPリストルール
        name = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    # CloudWatch設定
    visibility_config {

      # メトリクス有効化
      cloudwatch_metrics_enabled = true

      # メトリクス名
      metric_name = "IPReputationMetric"

      # サンプル保存
      sampled_requests_enabled = true
    }
  }
}

# WAFをALBへ関連付け
# ALBへの通信にWAFルールを適用する
resource "aws_wafv2_web_acl_association" "alb" {

  # WAF適用対象(ALB)
  resource_arn = aws_lb.main.arn

  # 関連付けするWeb ACL
  web_acl_arn = aws_wafv2_web_acl.main.arn
}