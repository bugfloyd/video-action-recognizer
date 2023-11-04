terraform {
  backend "s3" {
    key            = "var-state/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "var-terraform-state-lock"
  }
}
