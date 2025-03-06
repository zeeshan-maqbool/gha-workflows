terraform {
  backend "s3" {
    bucket         = "mgmt-terraform"
    key            = "gha-workflows/ecr/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mgmt-terraform"
  }
  required_version = "1.9.5"
}

provider "aws" {
  region = "us-west-2"
  alias = "org"

  assume_role {
    role_arn = "arn:aws:iam::205163962854:role/atlantis-sre"
  }

  default_tags {
    tags = {
      source       = "2uinc/gha-workflows/ecr"
      group        = "sre"
      businessunit = "SRE-Global"
      env          = terraform.workspace
    }
  }
}
