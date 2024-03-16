variable "main_zone_id" {
  description = "HostedZone ID of  the main domain"
  type        = string
}

variable "vpn_subdomain" {
  description = "The sub-domain used for the VPN server"
  type        = string
  default     = "vpn"
}

variable "private_subnet_id_az1" {
  description = "ID of the private subnet in AZ1"
  type        = string
}

variable "private_subnet_id_az2" {
  description = "ID of the private subnet in AZ2"
  type        = string
}

variable "private_subnet_cidr_block_az1" {
  description = "CIDR block of the private subnet in AZ1"
  type        = string
}

variable "private_subnet_cidr_block_az2" {
  description = "CIDR block of the private subnet in AZ2"
  type        = string
}

variable "vpn_client_cidr_block" {
  description = "CIDR block for VPN clients"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}