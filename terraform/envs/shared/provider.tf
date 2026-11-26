# 本番・検証で共有するリソース
# ACM・Route 53・ECS クラスター・ECR・SNS・画像用 S3＋CloudFront・アーティファクト用 S3・CodeConnections・Budgets
# VPC・NAT Gateway・ALB は環境ごと（envs/prod・envs/stg）

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # bucket は init 時に指定する: terraform init -backend-config="bucket=<bootstrap の出力>"
  backend "s3" {
    key          = "shared/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = var.project
      Environment = "shared"
      ManagedBy   = "terraform"
    }
  }
}
