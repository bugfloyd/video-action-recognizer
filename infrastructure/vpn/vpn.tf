data "aws_route53_zone" "main" {
  zone_id = var.main_zone_id
}

resource "aws_acm_certificate" "server_cert" {
  domain_name       = "${var.vpn_subdomain}.${data.aws_route53_zone.main.name}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.server_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.main_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "server_cert" {
  certificate_arn         = aws_acm_certificate.server_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_acm_certificate" "client_ca_cert" {
  private_key      = file("vpn/vpn_ca.key")
  certificate_body = file("vpn/vpn_ca.pem")
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "Client VPN endpoint"
  depends_on             = [aws_acm_certificate_validation.server_cert]
  server_certificate_arn = aws_acm_certificate.server_cert.arn

  client_cidr_block = var.vpn_client_cidr_block # CIDR block for the clients connected to the VPN
  split_tunnel      = true

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_ca_cert.arn
  }

  connection_log_options {
    enabled = false
  }

  transport_protocol = "udp"
}

resource "aws_ec2_client_vpn_network_association" "subnet_assoc_1" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = var.private_subnet_id_az1
}

resource "aws_ec2_client_vpn_network_association" "subnet_assoc_2" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = var.private_subnet_id_az2
}

resource "aws_ec2_client_vpn_authorization_rule" "allow_vpn_access_subnet_1" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = var.private_subnet_cidr_block_az1 # CIDR block you want VPN clients to access
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_authorization_rule" "allow_vpn_access_subnet_2" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = var.private_subnet_cidr_block_az2 # CIDR block of the second subnet
  authorize_all_groups   = true
}

#resource "aws_ec2_client_vpn_route" "internet_access" {
#  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
#  destination_cidr_block = "0.0.0.0/0" # Route for internet access
#  target_vpc_subnet_id   = aws_subnet.private_subnet_az1.id
#}