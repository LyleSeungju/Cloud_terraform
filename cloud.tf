terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "remote" {
    organization = "lyle_terraform_test"

    workspaces {
      name = "Cloud_terraform_test"
    }
  }
}
