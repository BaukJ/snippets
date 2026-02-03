terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  profile = var.aws_profile_main
}
provider "aws" {
  alias = "other"
  region = "eu-west-2"
  profile = var.aws_profile_main
}
