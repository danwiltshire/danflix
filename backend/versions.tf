terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    auth0 = {
      source  = "alexkappa/auth0"
      version = ">= 0.13"
    }
    archive = {
      source = "hashicorp/archive"
    }
  }
  required_version = ">= 0.13"
}
