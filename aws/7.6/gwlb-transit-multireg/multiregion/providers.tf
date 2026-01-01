# Secondary region provider (conditional)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [aws.secondary]
    }
  }
}

# Use data source instead of direct provider configuration
data "aws_region" "secondary" {
  provider = aws.secondary
}
