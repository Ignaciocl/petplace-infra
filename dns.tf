data "aws_route53_zone" "petplace" {
  name         = "lnt.digital"
  private_zone = false

  provider = aws
}

resource "aws_route53_record" "api_ssl" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.petplace.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_route53_record" "api_url" {
  zone_id = data.aws_route53_zone.petplace.zone_id
  name    = "api.lnt.digital"
  type    = "CNAME"
  records = [aws_lb.main.dns_name]
  ttl     = "60"

  allow_overwrite = true

}

resource "aws_route53_record" "frontend" {

  zone_id = data.aws_route53_zone.petplace.zone_id
  name    = "lnt.digital"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = true
  }

  allow_overwrite = true
}
