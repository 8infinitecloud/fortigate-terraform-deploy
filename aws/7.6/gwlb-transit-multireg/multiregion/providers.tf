# Secondary region provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [aws.secondary]
    }
  }
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}
