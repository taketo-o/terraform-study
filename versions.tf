#####################################################
# versions.tf
#####################################################

# Terraform自体のバージョンや
# 利用するProviderバージョンを定義する
terraform {

  # Terraform本体の必要バージョン
  # 1.5.0以上でのみ実行可能
  required_version = ">= 1.5.0"

  # 使用するProvider一覧
  required_providers {

    # AWS Provider設定
    aws = {

      # Providerの配布元
      # HashiCorp公式AWS Providerを利用
      source = "hashicorp/aws"

      # Providerバージョン指定
      # ~> 6.0 の意味:
      # 6.x系は許可するが7.0以上は許可しない
      version = "~> 6.0"
    }
  }
}