# インフラを構築する AWS のリージョン
variable "aws_region" {
  type        = string
  description = "インフラを構築する AWS のリージョン"
  default     = "ap-northeast-1"
}

# AWS Provider 実行時に使用するプロファイル名
variable "aws_profile" {
  type        = string
  description = "AWS profile name"
  default     = "activecore"
}

# 環境の名前
# Tag に含めることでリソースを区別するために使用
variable "environment" {
  type        = string
  description = "環境の名前 production | release | develop"
  default     = "release"
}

# Owner の名前
# Tag に含めることでリソースを区別するために使用
variable "owner" {
  type        = string
  description = "Owner の名前"
  default     = "activecore"
}

# Product の名前
# Tag に含めることでリソースを区別するために使用
variable "product" {
  type        = string
  description = "Product の名前"
  default     = "activecore"
}

# VPC CIDR
variable "vpc_cidr" {
  type        = string
  description = "VPC の CIDR"
  default     = "10.254.0.0/16"
}

# Cloudwatch log group の retention 日数
variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "Cloudwatch log group の retention 日数"
  default     = 30
}

# Logs の expiration days
variable "s3_logs_expiration_days" {
  type        = number
  description = "S3 bucket に保存されたログデータの保持期限(日)"
  default     = 365
}

# Terraform を実行する Profile の Account ID, User ID, and ARN を取得
data "aws_caller_identity" "this" {}

# provider aws に設定された region で使用可能な Availability Zone のリストを取得
data "aws_availability_zones" "this" {
  state = "available"
}

locals {
  # caller の account_id
  caller_account_id = data.aws_caller_identity.this.account_id

  # Terraform State ファイルを保存する bucket の名前
  s3_bucket_tfstate_name = "${local.caller_account_id}-tfstate-activecore-jp"

  # log を保存する bucket の名前
  s3_bucket_logs_name = "${local.caller_account_id}-logs-activecore-jp"

  # ALB access log を保存する bucket の名前
  s3_bucket_alb_access_logs_name = "${local.caller_account_id}-alb-access-logs-activecore-jp"
}
