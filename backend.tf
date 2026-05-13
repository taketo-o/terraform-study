terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "terraform-study/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}