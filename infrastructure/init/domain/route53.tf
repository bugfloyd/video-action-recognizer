variable "main_domain" {
  description = "The domain name for which to create the hosted zone"
  type        = string
}

resource "aws_route53_zone" "main" {
  name = var.main_domain
}

output "name_servers" {
  value = aws_route53_zone.main.name_servers
}

output "zone_id" {
  value = aws_route53_zone.main.zone_id
}