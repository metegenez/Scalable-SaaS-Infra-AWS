resource "aws_route53_record" "www" {
  zone_id = var.hosted_zone_id
  name    = "${var.backend_sub_domain_prefix}-${terraform.workspace}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.elb.dns_name
    zone_id                = var.elb.zone_id
    evaluate_target_health = true
  }
}
