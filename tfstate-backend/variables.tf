# インフラを構築する AWS のリージョン
variable "aws_region" {
  type        = string
  description = "インフラを構築する AWS のリージョン"
  default     = "ap-northeast-1"
}

# AWS Provider 実行時に使用するプロファイル名
variable "aws_profile" {
  type        = string
  description = "実行時に使用するプロファイル名"
  default     = "activecore"
}

# 環境の名前
# Tag に含めることでリソースを区別するために使用
variable "environment" {
  type        = string
  description = "環境の名前 prod | release | develop"
  default     = "release"
}

# Owner の名前
# Tag に含めることでリソースを区別するために使用
variable "owner" {
  type        = string
  description = "Owner の名前"
  default     = "activecore"
}

data "aws_caller_identity" "caller_identity" {}

locals {
  # caller の account_id
  caller_account_id = data.aws_caller_identity.caller_identity.account_id

  # Terraform State ファイルを保存する bucket の名前
  s3_bucket_tfstate_name = "${local.caller_account_id}-tfstate-activecore-jp"
}
