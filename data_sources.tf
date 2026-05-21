############################
# Data Source
############################

# 外部HTTP APIから情報を取得するデータソース
# Terraform実行時に動的な値を取得できる

data "http" "myip" {

  # 自分のグローバルIPアドレスを取得するAPI
  # https://checkip.amazonaws.com はIPのみを返すシンプルなサービス
  url = "https://checkip.amazonaws.com"
}