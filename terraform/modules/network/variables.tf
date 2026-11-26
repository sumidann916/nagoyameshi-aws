variable "name" {
  description = "例: nagoyameshi-prod"
  type        = string
}

variable "region" {
  type = string
}

variable "cidr_block" {
  description = "VPC の CIDR（本番 10.0.0.0/16・検証 10.1.0.0/16）。サブネットはこの中の /24 を使う"
  type        = string
}

variable "azs" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}
