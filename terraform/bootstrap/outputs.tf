output "tfstate_bucket" {
  description = "envs/*/ の terraform init -backend-config=\"bucket=...\" と tfstate_bucket 変数に指定する"
  value       = aws_s3_bucket.tfstate.bucket
}
