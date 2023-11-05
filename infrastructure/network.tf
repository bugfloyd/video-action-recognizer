# Create a VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VARecognizerVPC"
  }
}

# Private subnet in AZ1
resource "aws_subnet" "private_subnet_az1" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnetAZ1"
  }
}

# Private subnet in AZ2
resource "aws_subnet" "private_subnet_az2" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnetAZ2"
  }
}

# S3 VPC Endpoint for private access to S3 within the VPC
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.custom_vpc.id
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
  vpc_id             = aws_vpc.custom_vpc.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
  security_group_ids = [aws_security_group.ecr_sg.id]

  private_dns_enabled = true
}

# ECR Docker endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = aws_vpc.custom_vpc.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
  security_group_ids = [aws_security_group.ecr_sg.id]

  private_dns_enabled = true
}

# Security group for the ECR VPC endpoints
resource "aws_security_group" "ecr_sg" {
  name   = "ecr_vpc_endpoint_sg"
  vpc_id = aws_vpc.custom_vpc.id

  # Add rules that allow inbound and outbound traffic necessary for ECR
}

# Route table associated with the private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
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
