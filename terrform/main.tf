terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }

  required_version = ">= 1.3.6"

  backend "s3" {
    key            = "activecore"
    dynamodb_table = "dynamodb_table_tfstate_lock"
    encrypt        = true
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Owner       = var.owner
      Product     = var.product
      ToolName    = "Terraform"
    }
  }
}

