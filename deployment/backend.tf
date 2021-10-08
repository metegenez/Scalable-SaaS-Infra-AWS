terraform {
  backend "s3" {
    bucket = "cloudvisor-terraform"
    region = "us-east-1"
    key = "terraform.tfstate"
  }
}