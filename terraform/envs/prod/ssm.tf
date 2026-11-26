resource "aws_ssm_parameter" "managed" {
  for_each = local.managed_params
  name     = "${local.ssm_path}/${each.key}"
  type     = each.value.type
  value    = each.value.value
}
