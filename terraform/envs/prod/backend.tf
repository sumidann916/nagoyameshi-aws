# bucket は init 時に指定する: terraform init -backend-config="bucket=<bootstrap の出力>"
terraform {
  backend "s3" {
    key          = "prod/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
