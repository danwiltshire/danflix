terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.39.0"
    }
    auth0 = {
      source  = "alexkappa/auth0"
      version = "0.21.0"
    }
  }
  required_version = "0.15.3"
}
