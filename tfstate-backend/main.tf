terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }

  required_version = ">= 1.3.6"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Owner       = var.owner
    }
  }
}

# アカウント全体に渡り S3 Bucket の publick access を block
resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Terraform State ファイルを保存する S3 Bucket
resource "aws_s3_bucket" "s3_bucket_tfstate" {
  bucket = local.s3_bucket_tfstate_name

  # 誤って削除することを防ぐ
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = local.s3_bucket_tfstate_name
  }
}

# s3_bucket_tfstate の public access を block
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.s3_bucket_tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.s3_bucket_tfstate.id
  acl    = "private"
}

# s3_bucket_tfstate を暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.s3_bucket_tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# tfstate は過去の version も含めて保存
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.s3_bucket_tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 排他的 LOCK を管理するための DynamoDB Table
# State ファイルの同時更新を防止する
resource "aws_dynamodb_table" "dynamodb_table_tfstate_lock" {
  name           = "dynamodb_table_tfstate_lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "dynamodb_table_tfstate_lock"
  }
}
