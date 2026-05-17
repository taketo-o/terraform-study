terraform {
  backend "s3" {
    bucket         = "tfstate-2026-fubuki"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-lock"
  }
}