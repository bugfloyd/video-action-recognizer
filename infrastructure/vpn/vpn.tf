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
  split_tunnel      = false
  transport_protocol = "udp"
  dns_servers        = ["1.1.1.1"]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_ca_cert.arn
  }

  connection_log_options {
    enabled = true
    cloudwatch_log_group = aws_cloudwatch_log_group.vpn_log_group.name
  }
}

resource "aws_cloudwatch_log_group" "vpn_log_group" {
  name = "client_vpn"
  retention_in_days = 30 # Optional: Configure log retention policy. Adjust as needed.
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

# Provide Internet access
resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet_az3" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnetAZ3"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet_az3.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_ec2_client_vpn_network_association" "public_subnet_assoc_az3" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = aws_subnet.public_subnet_az3.id
}

resource "aws_ec2_client_vpn_route" "internet_access" {
  depends_on             = [aws_ec2_client_vpn_network_association.public_subnet_assoc_az3]
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  destination_cidr_block = "0.0.0.0/0" # Route for internet access
  target_vpc_subnet_id   = aws_subnet.public_subnet_az3.id
}

resource "aws_ec2_client_vpn_authorization_rule" "allow_internet_access" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = "0.0.0.0/0" # CIDR block of the second subnet
  authorize_all_groups   = true
}