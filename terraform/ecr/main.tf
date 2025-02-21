terraform {
  backend "s3" {
    bucket         = "mgmt-terraform"
    key            = "gha-workflows/ecr/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mgmt-terraform"
  }
  required_version = "1.9.5"
  #   required_providers {
  #     aws = {
  #       source = "hashicorp/aws"
  #     }
  #     datadog = {
  #       source = "datadog/datadog"
  #     }
  #     github = {
  #       source  = "integrations/github"
  #       version = "6.2.2"
  #     }
  #     kubernetes = {
  #       source = "hashicorp/kubernetes"
  #     }
  #     kustomization = {
  #       source = "kbst/kustomization"
  #     }
  #     castai = {
  #       source = "castai/castai"
  #     }
  #   }
}
