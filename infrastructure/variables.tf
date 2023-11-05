variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "input_bucket" {
  description = "The AWS S3 bucket for storing input videos"
  type        = string
}

variable "output_bucket" {
  description = "The AWS S3 bucket for storing output videos"
  type        = string
}
