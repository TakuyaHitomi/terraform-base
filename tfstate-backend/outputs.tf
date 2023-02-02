# インフラを構築する AWS のリージョン
output "aws_region" {
  value = var.aws_region
}

# Terraform State ファイルを保存する bucket の名前
output "s3_bucket_tfstate_name" {
  value = local.s3_bucket_tfstate_name
}

# Terraform State ロックを保存する dynamodb table の名前
output "dynamodb_table_tfstate_lock_name" {
  value = "dynamodb_table_tfstate_lock"
}
