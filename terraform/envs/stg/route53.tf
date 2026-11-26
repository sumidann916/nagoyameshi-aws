resource "aws_route53_record" "app" {
  zone_id = local.s.zone_id
  name    = local.host_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}
