terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.45"
    }
  }

  # aws s3api create-bucket --bucket dmitry-grinko-aws-templates-lamnbda-tfstate --region us-east-1
  backend "s3" {
    bucket = "dmitry-grinko-aws-templates-lamnbda-tfstate"
    key    = "state.tfstate"
    region = "us-east-1"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = var.aws-region
  access_key = var.aws-access-key-id
  secret_key = var.aws-secret-access-key
}