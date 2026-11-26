# envs/prod・envs/stg が terraform_remote_state で参照する

output "domain_name" {
  value = var.domain_name
}

output "zone_id" {
  value = data.aws_route53_zone.this.zone_id
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "app_subnet_ids" {
  value = module.network.app_subnet_ids
}

output "db_subnet_ids" {
  value = module.network.db_subnet_ids
}

output "alb_arn_suffix" {
  value = module.alb.alb_arn_suffix
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_zone_id" {
  value = module.alb.alb_zone_id
}

output "alb_sg_id" {
  value = module.alb.alb_sg_id
}

output "https_listener_arn" {
  value = module.alb.https_listener_arn
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
