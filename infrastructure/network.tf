# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VARecognizerVPC"
  }
}

# Private subnet in AZ1
resource "aws_subnet" "private_subnet_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnetAZ1"
  }
}

# Private subnet in AZ2
resource "aws_subnet" "private_subnet_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnetAZ2"
  }
}

# Route table associated with the private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
}

# Associate the route table with private subnet AZ1
resource "aws_route_table_association" "private_az1_association" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate the route table with private subnet AZ2
resource "aws_route_table_association" "private_az2_association" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_route_table.id
}

# S3 VPC Endpoint for private access to S3 within the VPC
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    # Route table for private subnets
    aws_route_table.private_route_table.id,
  ]
  tags = {
    Name = "S3VpcEndpoint"
  }
}

# ECR API endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  tags = {
    Name = "EcrApiVpcEndpoint"
  }
}

# ECR Docker endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  tags = {
    Name = "EcrDkrVpcEndpoint"
  }
}

# Cloudwatch endpoint
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  tags = {
    Name = "CloudWatchLogsVpcEndpoint"
  }
}

# Cloudwatch endpoint
resource "aws_vpc_endpoint" "cloudwatch_monitoring" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.monitoring"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  tags = {
    Name = "CloudWatchMonitoringVpcEndpoint"
  }
}

resource "aws_security_group" "vpc_endpoints" {
  # name        = "vpc-endpoints-sg"
  description = "Security Group for VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.analysis_core_sg.id]
  }

  // Allow outbound traffic to the ECS tasks (return traffic)
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.analysis_core_sg.id]
  }
  tags = {
    Name = "VpcEndpoints"
  }
}

# Security group for ECS task
resource "aws_security_group" "analysis_core_sg" {
  vpc_id      = aws_vpc.main.id
  description = "Security group for ECS tasks"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EcsTaskSG"
  }
}

# Security group for Lambda functions
resource "aws_security_group" "upload_listener_lambda_sg" {
  vpc_id      = aws_vpc.main.id
  description = "Security group for Lambda functions"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "LambdaSG"
  }
}
