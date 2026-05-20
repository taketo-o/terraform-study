# Terraform自体の設定ブロック
terraform {

  # TerraformのStateファイル保存先(Backend)を定義
  # backend "s3" を使うことで、stateをAWS S3へ保存できる
  backend "s3" {

    # tfstateファイルを保存するS3バケット名
    # Terraformのインフラ状態(State)がここに保存される
    bucket = "tfstate-2026-fubuki"

    # S3内での保存パス
    # dev環境用のterraform.tfstateという意味
    key = "dev/terraform.tfstate"

    # S3バケットが存在するAWSリージョン
    region = "ap-northeast-1"

    # State Lock用のDynamoDBテーブル
    # 複数人やCI/CDが同時にterraform applyしないよう制御する
    # State破損防止のため非常に重要
    dynamodb_table = "terraform-lock"
  }
}