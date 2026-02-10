terraform {
  backend "s3" {
    bucket         = "mani-terraform-state-2025"
    key            = "static-site/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
