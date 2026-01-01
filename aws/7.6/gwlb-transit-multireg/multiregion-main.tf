# Multiregion Module
module "multiregion" {
  count  = var.enable_multiregion ? 1 : 0
  source = "./multiregion"
  
  # Pass variables to module
  enable_multiregion = var.enable_multiregion
  secondary_region   = var.secondary_region
  
  # Pass primary region variables for cross-region routing
  vpccidr    = var.vpccidr
  csvpccidr  = var.csvpccidr
  cs2vpccidr = var.cs2vpccidr
  
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
  
  # Only configure when multiregion is enabled
  skip_credentials_validation = var.enable_multiregion ? false : true
  skip_metadata_api_check     = var.enable_multiregion ? false : true
  skip_region_validation      = var.enable_multiregion ? false : true
}
