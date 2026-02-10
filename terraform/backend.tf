terraform {
  backend "s3" {
    bucket         = "mani-static-terraform"
    key            = "static-site/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
