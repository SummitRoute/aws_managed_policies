provider "aws" {
  region = "${var.aws_region}"
  version = "3.13.0"
}

terraform {
  backend "s3" {
    region = "eu-west-1"
  }
}