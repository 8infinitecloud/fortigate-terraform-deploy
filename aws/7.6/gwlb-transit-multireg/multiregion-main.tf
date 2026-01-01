# Multiregion Module
module "multiregion" {
  count  = var.enable_multiregion ? 1 : 0
  source = "./multiregion"
  
  # Pass variables to module
  enable_multiregion = var.enable_multiregion
  secondary_region   = var.secondary_region
  
  # Pass GWLB service name for cross-region inspection
  primary_gwlb_service_name = aws_vpc_endpoint_service.fgtgwlbservice.service_name
  
  providers = {
    aws.secondary = aws.secondary
  }
}

# Secondary region provider (only when multiregion is enabled)
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}
