############################
# VPC
############################

# VPC(Virtual Private Cloud)を作成
# AWS上に独立したネットワーク空間を構築する
resource "aws_vpc" "main" {

  # VPCのCIDRブロック
  # 10.0.0.0 ～ 10.0.255.255 の範囲を使用
  cidr_block = "10.0.0.0/16"

  # VPC内でDNS解決を有効化
  # EC2からドメイン名解決できるようになる
  enable_dns_support = true

  # EC2へDNSホスト名を付与
  # Public DNS名などが利用可能になる
  enable_dns_hostnames = true

  # AWSコンソール用タグ
  tags = {

    # VPC名
    Name = "aws-study-vpc"
  }
}

############################
# Subnets
############################

# パブリックサブネット(ap-northeast-1a)
# インターネット接続可能なサブネット
resource "aws_subnet" "public_1a" {

  # 所属VPC
  vpc_id = aws_vpc.main.id

  # サブネットCIDR
  # 10.0.1.0 ～ 10.0.1.255
  cidr_block = "10.0.1.0/24"

  # 配置AZ
  availability_zone = "ap-northeast-1a"

  # EC2起動時に自動でPublic IP付与
  # インターネット接続可能になる
  map_public_ip_on_launch = true
}

# パブリックサブネット(ap-northeast-1c)
resource "aws_subnet" "public_1c" {

  # 所属VPC
  vpc_id = aws_vpc.main.id

  # CIDR範囲
  cidr_block = "10.0.2.0/24"

  # AZ
  availability_zone = "ap-northeast-1c"

  # Public IP自動付与
  map_public_ip_on_launch = true
}

# プライベートサブネット(ap-northeast-1a)
# 外部インターネットから直接アクセスされないサブネット
resource "aws_subnet" "private_1a" {

  # 所属VPC
  vpc_id = aws_vpc.main.id

  # CIDR範囲
  cidr_block = "10.0.3.0/24"

  # AZ
  availability_zone = "ap-northeast-1a"
}

# プライベートサブネット(ap-northeast-1c)
resource "aws_subnet" "private_1c" {

  # 所属VPC
  vpc_id = aws_vpc.main.id

  # CIDR範囲
  cidr_block = "10.0.4.0/24"

  # AZ
  availability_zone = "ap-northeast-1c"
}

############################
# Internet Gateway
############################

# Internet Gatewayを作成
# VPCをインターネットへ接続するために必要
resource "aws_internet_gateway" "igw" {

  # 接続対象VPC
  vpc_id = aws_vpc.main.id
}

############################
# Route Table
############################

# パブリック用ルートテーブル作成
# 通信経路(Route)を管理する
resource "aws_route_table" "public" {

  # 対象VPC
  vpc_id = aws_vpc.main.id
}

# デフォルトルート追加
# インターネット向け通信をInternet Gatewayへ転送
resource "aws_route" "internet_access" {

  # 対象ルートテーブル
  route_table_id = aws_route_table.public.id

  # 全通信宛先
  # 0.0.0.0/0 = インターネット全体
  destination_cidr_block = "0.0.0.0/0"

  # 転送先Internet Gateway
  gateway_id = aws_internet_gateway.igw.id
}

# public_1a サブネットへルートテーブル関連付け
resource "aws_route_table_association" "public_1a" {

  # 関連付け対象サブネット
  subnet_id = aws_subnet.public_1a.id

  # 使用するルートテーブル
  route_table_id = aws_route_table.public.id
}

# public_1c サブネットへルートテーブル関連付け
resource "aws_route_table_association" "public_1c" {

  # 関連付け対象サブネット
  subnet_id = aws_subnet.public_1c.id

  # 使用するルートテーブル
  route_table_id = aws_route_table.public.id
}