# envs/prod・envs/stg が terraform_remote_state で参照する

output "domain_name" {
  value = var.domain_name
}

output "zone_id" {
  value = data.aws_route53_zone.this.zone_id
}

output "certificate_arn" {
  description = "検証済みの証明書（example.com と *.example.com）。本番・検証の ALB で使う"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecr_repository_urls" {
  value = { for k, r in aws_ecr_repository.this : k => r.repository_url }
}

output "ecr_repository_arns" {
  value = { for k, r in aws_ecr_repository.this : k => r.arn }
}

output "sns_topic_arn" {
  value = aws_sns_topic.alarm.arn
}

output "images_bucket" {
  value = aws_s3_bucket.images.bucket
}

output "images_bucket_arn" {
  value = aws_s3_bucket.images.arn
}

output "images_cdn_domain" {
  value = aws_cloudfront_distribution.images.domain_name
}

output "artifact_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}

output "github_connection_arn" {
  value = aws_codestarconnections_connection.github.arn
}
