#####################################################
# variables.tf
#####################################################

# RDSのマスターユーザー名を受け取る変数
variable "db_username" {

  # 変数の説明
  description = "RDS master username"

  # データ型
  # string = 文字列
  type = string
}

# RDSのマスターパスワードを受け取る変数
variable "db_password" {

  # 変数の説明
  description = "RDS master password"

  # データ型
  type = string

  # sensitive = true
  # terraform plan/apply時に値を非表示にする
  # パスワード漏洩防止
  sensitive = true
}

# CloudWatch Alarm通知先メールアドレス
# SNS通知に利用される
variable "notification_email" {

  # 変数説明
  description = "CloudWatch SNS notification email"

  # 文字列型
  type = string
}

# EC2へSSH接続するためのKey Pair名
variable "key_pair_name" {

  # 変数説明
  description = "EC2 Key Pair Name"

  # 文字列型
  type = string
}

# SSH秘密鍵(.pem)のパス
# AnsibleやSSH接続時に使用する想定
variable "ssh_private_key_path" {

  # 文字列型
  type = string
}